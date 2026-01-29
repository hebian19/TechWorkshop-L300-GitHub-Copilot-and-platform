using System.Text;
using System.Text.Json;
using Azure.Core;
using Azure.Identity;

namespace ZavaStorefront.Services
{
    public class ChatService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<ChatService> _logger;
        private readonly HttpClient _httpClient;
        private readonly DefaultAzureCredential _credential;

        public ChatService(IConfiguration configuration, ILogger<ChatService> logger, IHttpClientFactory httpClientFactory)
        {
            _configuration = configuration;
            _logger = logger;
            _httpClient = httpClientFactory.CreateClient();
            _credential = new DefaultAzureCredential();
        }

        public async Task<string> SendMessageAsync(string userMessage)
        {
            try
            {
                var endpoint = _configuration["Phi4:Endpoint"];
                var deploymentName = _configuration["Phi4:DeploymentName"];

                if (string.IsNullOrEmpty(endpoint) || string.IsNullOrEmpty(deploymentName))
                {
                    _logger.LogError("Phi4 endpoint configuration is missing");
                    return "Chat service is not configured. Please contact the administrator.";
                }

                var requestUrl = $"{endpoint.TrimEnd('/')}/openai/deployments/{deploymentName}/chat/completions?api-version=2024-08-01-preview";

                // Get access token using managed identity
                var tokenRequestContext = new TokenRequestContext(new[] { "https://cognitiveservices.azure.com/.default" });
                var accessToken = await _credential.GetTokenAsync(tokenRequestContext);

                var requestBody = new
                {
                    messages = new[]
                    {
                        new { role = "system", content = "You are a helpful assistant for Zava Storefront. Help customers with product inquiries and general questions." },
                        new { role = "user", content = userMessage }
                    },
                    max_tokens = 800,
                    temperature = 0.7
                };

                var jsonContent = JsonSerializer.Serialize(requestBody);
                var httpContent = new StringContent(jsonContent, Encoding.UTF8, "application/json");

                using var request = new HttpRequestMessage(HttpMethod.Post, requestUrl);
                request.Headers.Add("Authorization", $"Bearer {accessToken.Token}");
                request.Content = httpContent;

                _logger.LogInformation("Sending message to Phi4 endpoint");

                var response = await _httpClient.SendAsync(request);
                var responseContent = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError("Phi4 API request failed with status {StatusCode}: {Response}", response.StatusCode, responseContent);
                    return "Unable to process your request at this time. Please try again later.";
                }

                try
                {
                    var jsonResponse = JsonDocument.Parse(responseContent);
                    if (!jsonResponse.RootElement.TryGetProperty("choices", out var choices) || 
                        choices.GetArrayLength() == 0)
                    {
                        _logger.LogError("Unexpected API response format: no choices found");
                        return "Unable to process your request at this time. Please try again later.";
                    }

                    var assistantMessage = choices[0]
                        .GetProperty("message")
                        .GetProperty("content")
                        .GetString();

                    return assistantMessage ?? "No response received.";
                }
                catch (JsonException ex)
                {
                    _logger.LogError(ex, "Failed to parse API response");
                    return "Unable to process the response. Please try again later.";
                }
            }
            catch (TaskCanceledException ex)
            {
                _logger.LogWarning(ex, "Request to Phi4 endpoint was canceled or timed out");
                return "The request timed out. Please try again.";
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "HTTP error calling Phi4 endpoint");
                return "Unable to reach the chat service. Please try again later.";
            }
            catch (AuthenticationFailedException ex)
            {
                _logger.LogError(ex, "Authentication failed while acquiring token for Phi4 endpoint");
                return "The chat service is temporarily unavailable due to authentication issues. Please try again later.";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error calling Phi4 endpoint");
                return "An unexpected error occurred. Please try again later.";
            }
        }
    }
}
