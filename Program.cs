
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Zooshop.Data;

namespace Zooshop
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            builder.WebHost.UseKestrel(serverOptions =>
            {

                serverOptions.ListenAnyIP(5000);
                serverOptions.ListenAnyIP(5001, listenOptions => listenOptions.UseHttps());
            });
            builder.Services.AddCors(options =>
            {
                // Добавляем именованную политику CORS с названием "AllowAngular".
                options.AddPolicy("AllowAngular", policy =>
                {
                    // Разрешаем запросы только с указанного источника: http://localhost:4200.
                    policy.WithOrigins("https://zooshop-61f32.firebaseapp.com")
                        // Разрешаем любые HTTP-методы (GET, POST, PUT, DELETE и т.д.).
                        .AllowAnyMethod()
                        // Разрешаем любые заголовки в запросах (например, Content-Type, Authorization).
                        .AllowAnyHeader()
                        // Разрешаем отправку учётных данных (например, cookies, HTTP-аутентификация).
                        .AllowCredentials();
                });
            });

            builder.Services.AddDbContext<AppDbContext>(options =>
            options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

            builder.Services.AddControllers();
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            var app = builder.Build();

            app.UseSwagger();
            app.UseSwaggerUI();


            //app.UseHttpsRedirection();

            app.UseAuthorization();

            app.UseCors("AllowAngular");

            app.MapControllers();

            app.Run();
        }
    }
}
