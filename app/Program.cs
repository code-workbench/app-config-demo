using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add CORS for development
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors();
app.UseStaticFiles();
app.UseRouting();

// API endpoint to get environment variables
app.MapGet("/api/config", () =>
{
    var testSetting = Environment.GetEnvironmentVariable("TEST_SETTING") ?? "Not set";
    var testSecret = Environment.GetEnvironmentVariable("TEST_SECRET") ?? "Not set";
    
    return Results.Ok(new
    {
        TestSetting = testSetting,
        TestSecret = testSecret,
        Timestamp = DateTime.UtcNow
    });
});

// Serve the HTML page
app.MapGet("/", () => Results.Content(GetIndexHtml(), "text/html"));

app.Run();

static string GetIndexHtml()
{
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Environment Variables for App Service Demo</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            padding: 40px;
            max-width: 600px;
            width: 100%;
            text-align: center;
        }

        h1 {
            color: #333;
            margin-bottom: 30px;
            font-size: 2.5rem;
            font-weight: 300;
        }

        .config-item {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 20px;
            margin: 20px 0;
            border-left: 4px solid #667eea;
            text-align: left;
        }

        .config-label {
            font-weight: 600;
            color: #495057;
            font-size: 1.1rem;
            margin-bottom: 8px;
        }

        .config-value {
            background: #e9ecef;
            padding: 12px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
            color: #495057;
            word-break: break-all;
            border: 1px solid #dee2e6;
        }

        .refresh-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 50px;
            font-size: 1.1rem;
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            margin-top: 30px;
        }

        .refresh-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        .timestamp {
            color: #6c757d;
            font-size: 0.9rem;
            margin-top: 20px;
            font-style: italic;
        }

        .loading {
            opacity: 0.6;
            pointer-events: none;
        }

        .error {
            background: #f8d7da;
            color: #721c24;
            border-left-color: #dc3545;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .config-item {
            animation: fadeIn 0.5s ease forwards;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 Environment Variables</h1>
        
        <div id="config-container">
            <div class="config-item">
                <div class="config-label">TEST_SETTING</div>
                <div class="config-value" id="test-setting">Loading...</div>
            </div>
            
            <div class="config-item">
                <div class="config-label">TEST_SECRET</div>
                <div class="config-value" id="test-secret">Loading...</div>
            </div>
        </div>
        
        <button class="refresh-btn" onclick="loadConfig()">🔄 Refresh</button>
        
        <div class="timestamp" id="timestamp"></div>
    </div>

    <script>
        async function loadConfig() {
            const container = document.getElementById('config-container');
            const refreshBtn = document.querySelector('.refresh-btn');
            
            // Add loading state
            container.classList.add('loading');
            refreshBtn.disabled = true;
            refreshBtn.textContent = '⏳ Loading...';
            
            try {
                const response = await fetch('/api/config');
                
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                
                const data = await response.json();
                
                // Update the values
                document.getElementById('test-setting').textContent = data.testSetting;
                document.getElementById('test-secret').textContent = data.testSecret;
                document.getElementById('timestamp').textContent = 
                    `Last updated: ${new Date(data.timestamp).toLocaleString()}`;
                
                // Remove error state if it exists
                document.querySelectorAll('.config-item').forEach(item => {
                    item.classList.remove('error');
                });
                
            } catch (error) {
                console.error('Error fetching config:', error);
                
                // Show error state
                document.getElementById('test-setting').textContent = 'Error loading value';
                document.getElementById('test-secret').textContent = 'Error loading value';
                document.getElementById('timestamp').textContent = 
                    `Error: ${error.message}`;
                
                // Add error styling
                document.querySelectorAll('.config-item').forEach(item => {
                    item.classList.add('error');
                });
            } finally {
                // Remove loading state
                container.classList.remove('loading');
                refreshBtn.disabled = false;
                refreshBtn.textContent = '🔄 Refresh';
            }
        }
        
        // Load config on page load
        document.addEventListener('DOMContentLoaded', loadConfig);
        
        // Auto-refresh every 30 seconds
        setInterval(loadConfig, 30000);
    </script>
</body>
</html>
""";
}
