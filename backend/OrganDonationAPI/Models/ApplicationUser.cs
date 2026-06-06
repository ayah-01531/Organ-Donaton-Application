using Microsoft.AspNetCore.Identity;

public class ApplicationUser : IdentityUser
{
    public string FullName { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty; // Donor, Hospital, Ministry, NationalCenter
    public string LicenseNumber { get; set; } = string.Empty; // For hospitals  
}