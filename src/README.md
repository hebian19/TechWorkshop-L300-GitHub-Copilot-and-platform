# Zava Storefront - ASP.NET Core MVC

A simple e-commerce storefront application built with .NET 6 ASP.NET MVC.

## Features

- **Product Listing**: Browse a catalog of 8 sample products with images, descriptions, and prices
- **Shopping Cart**: Add products to cart with session-based storage
- **Cart Management**: View cart, update quantities, remove items
- **Checkout**: Simple checkout process that clears cart and shows success message
- **AI Chat Assistant**: Interactive chat powered by Microsoft Foundry Phi-4 model for customer support and product inquiries
- **Responsive Design**: Mobile-friendly layout using Bootstrap 5

## Technology Stack

- .NET 6
- ASP.NET Core MVC
- Bootstrap 5
- Bootstrap Icons
- Azure Identity SDK for managed identity authentication
- Microsoft Foundry (Azure AI Services) with Phi-4 model
- Session-based state management (no database)

## Project Structure

```
ZavaStorefront/
├── Controllers/
│   ├── HomeController.cs      # Products listing and add to cart
│   ├── CartController.cs       # Cart operations and checkout
│   └── ChatController.cs       # Chat interface and API endpoints
├── Models/
│   ├── Product.cs              # Product model
│   └── CartItem.cs             # Cart item model
├── Services/
│   ├── ProductService.cs       # Static product data
│   ├── CartService.cs          # Session-based cart management
│   └── ChatService.cs          # Microsoft Foundry Phi-4 integration
├── Views/
│   ├── Home/
│   │   └── Index.cshtml        # Products listing page
│   ├── Cart/
│   │   ├── Index.cshtml        # Shopping cart page
│   │   └── CheckoutSuccess.cshtml  # Checkout success page
│   ├── Chat/
│   │   └── Index.cshtml        # Chat interface page
│   └── Shared/
│       └── _Layout.cshtml      # Main layout with cart icon
└── wwwroot/
    ├── css/
    │   └── site.css            # Custom styles
    └── images/
        └── products/           # Product images directory
```

## How to Run

1. Navigate to the project directory:
   ```bash
   cd ZavaStorefront
   ```

2. Configure the Phi-4 endpoint (see **Chat Feature Configuration** section below)

3. Run the application:
   ```bash
   dotnet run
   ```

4. Open your browser and navigate to:
   ```
   https://localhost:5001
   ```

## Chat Feature Configuration

The chat feature requires configuration to connect to your Microsoft Foundry Phi-4 deployment. You can configure this in one of three ways:

### Option 1: User Secrets (Recommended for Development)

```bash
dotnet user-secrets set "Phi4:Endpoint" "https://your-foundry-endpoint.openai.azure.com/"
dotnet user-secrets set "Phi4:DeploymentName" "phi-4"
```

### Option 2: Environment Variables

```bash
export Phi4__Endpoint="https://your-foundry-endpoint.openai.azure.com/"
export Phi4__DeploymentName="phi-4"
```

### Option 3: appsettings.json (Not recommended for production)

Update the `appsettings.json` file:

```json
{
  "Phi4": {
    "Endpoint": "https://your-foundry-endpoint.openai.azure.com/",
    "DeploymentName": "phi-4"
  }
}
```

### Authentication

The chat feature uses **Azure Managed Identity** for authentication. When running locally, it uses `DefaultAzureCredential` which will attempt to authenticate using:
1. Environment variables (for Azure service principal)
2. Azure CLI credentials
3. Azure PowerShell credentials
4. Visual Studio credentials
5. Visual Studio Code credentials

For local development, ensure you're logged in to Azure CLI:
```bash
az login
```

When deployed to Azure App Service with a system-assigned managed identity, authentication happens automatically without any credentials.

## Product Images

The application includes 8 sample products. Product images are referenced from:
- `/wwwroot/images/products/`

If images are not found, the application automatically falls back to placeholder images from placeholder.com.

To add custom product images, place JPG files in `wwwroot/images/products/` with these names:
- headphones.jpg
- smartwatch.jpg
- speaker.jpg
- charger.jpg
- usb-hub.jpg
- keyboard.jpg
- mouse.jpg
- webcam.jpg

## Sample Products

1. Wireless Bluetooth Headphones - $89.99
2. Smart Fitness Watch - $199.99
3. Portable Bluetooth Speaker - $49.99
4. Wireless Charging Pad - $29.99
5. USB-C Hub Adapter - $39.99
6. Mechanical Gaming Keyboard - $119.99
7. Ergonomic Wireless Mouse - $34.99
8. HD Webcam - $69.99

## Application Flow

1. **Landing Page**: Displays all products in a responsive grid
2. **Add to Cart**: Click "Buy" button to add products to cart
3. **View Cart**: Click cart icon (top right) to view cart contents
4. **Update Cart**: Modify quantities or remove items
5. **Checkout**: Click "Checkout" button to complete purchase
6. **Success**: View confirmation and return to products
7. **Chat**: Click "Chat" in the navigation to access the AI assistant for product inquiries and support

## Session Management

- Cart data is stored in session
- Session timeout: 30 minutes
- No data persistence (cart clears when session expires)
- Cart is cleared after successful checkout

## Logging

The application includes structured logging for:
- Product page loads
- Adding products to cart
- Cart operations (update, remove)
- Checkout process
- Chat messages and API calls to Microsoft Foundry
- Authentication and error handling

Logs are written to console during development.

## Chat Feature Details

### Features
- Real-time interactive chat interface
- Conversation history displayed in a scrollable area
- Error handling with user-friendly messages
- Loading indicators during API calls
- Responsive design matching the overall application style

### Security
- Uses Azure Managed Identity for authentication (no API keys)
- All API calls are authenticated using DefaultAzureCredential
- HTTPS required for production deployments
- Input validation and sanitization

### Error Handling
The chat service includes comprehensive error handling:
- Configuration validation (missing endpoint or deployment name)
- HTTP error responses with status codes
- Network connectivity issues
- JSON parsing errors
- User-friendly error messages displayed in the UI

### API Integration
The chat feature integrates with Microsoft Foundry using:
- OpenAI-compatible API endpoint format
- Chat completions API with system and user messages
- Configurable temperature and max_tokens parameters
- Standard Bearer token authentication
