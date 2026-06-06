using Microsoft.EntityFrameworkCore.Metadata;

namespace OrganDonationAPI.Models
{
    public class Donor
    {
        public int Id { get; set; }
        public string UserId { get; set; } = string.Empty;
        public ApplicationUser User { get; set; } = null!;
         public string FullName { get; set; } = string.Empty;
        public string NationalId { get; set; } = string.Empty;
        public string BloodType { get; set; } = string.Empty;
        public DateTime DateOfBirth { get; set; }
        public string Address { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string OrgansToDonat { get; set; } = string.Empty; // JSON list
        public string? MedicalConditions { get; set; }
        public string? MedicalReportsPath { get; set; }
        public string Status { get; set; } = "Pending"; // Pending, Approved, Rejected

        public string RejectionReason { get; set; } = string.Empty;

        public DateTime RegisteredAt { get; set; } = DateTime.UtcNow;

        public string? DeathCertificatePath { get; set; }
        public DateTime? DateOfDeath { get; set; }
    }
}

