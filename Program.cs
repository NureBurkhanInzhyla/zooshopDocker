
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
            builder.WebHost.ConfigureKestrel(options =>
            {
                options.ListenAnyIP(8080);
            });
            builder.Services.AddCors(options =>
            {
                // Добавляем именованную политику CORS с названием "AllowAngular".
                options.AddPolicy("AllowAngular", policy =>
                {
                    // Разрешаем запросы только с указанного источника: http://localhost:4200.
                    policy.WithOrigins("http://localhost:50258")
                        // Разрешаем любые HTTP-методы (GET, POST, PUT, DELETE и т.д.).
                        .AllowAnyMethod()
                        // Разрешаем любые заголовки в запросах (например, Content-Type, Authorization).
                        .AllowAnyHeader()
                        // Разрешаем отправку учётных данных (например, cookies, HTTP-аутентификация).
                        .AllowCredentials();
                });
            });

            var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
            connectionString = connectionString.Replace("|DataDirectory|", AppDomain.CurrentDomain.BaseDirectory);

            builder.Services.AddDbContext<AppDbContext>(options =>
                options.UseSqlite(connectionString));

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
