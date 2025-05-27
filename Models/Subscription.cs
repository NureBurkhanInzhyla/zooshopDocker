using System.ComponentModel.DataAnnotations;

namespace Zooshop.Models
{
    public class Subscription
    {
        public int Id { get; set; }
        [Required]
        public int UserId { get; set; }
        public int ProductId { get; set; }
        public int DeliveryFrequency { get; set; }
        public string StartDate { get; set; }
    }
}