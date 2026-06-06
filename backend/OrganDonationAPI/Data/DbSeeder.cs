
using Microsoft.AspNetCore.Identity;
using OrganDonationAPI.Models;

namespace OrganDonationAPI.Data
{
    public static class AppRoles
    {
        public const string MinistryAdmin = "MinistryAdmin";
        public const string HospitalAdmin = "HospitalAdmin";
        public const string Donor = "Donor";
    }

    public static class DbSeeder
    {
        public static async Task SeedAsync(IServiceProvider services)
        {
            var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();
            var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();

            string[] roles = { AppRoles.MinistryAdmin, AppRoles.HospitalAdmin, AppRoles.Donor };
            foreach (var role in roles)
            {
                if (!await roleManager.RoleExistsAsync(role))
                    await roleManager.CreateAsync(new IdentityRole(role));
            }

            var ministryEmail = "ministry@health.gov.jo";
            if (await userManager.FindByEmailAsync(ministryEmail) == null)
            {
                var admin = new ApplicationUser
                {

                    FullName = "Ministry of Health",
                    Email = "ministry@organ.jo",
                    UserName = "ministry@organ.jo",
                    Role = "MinistryAdmin",
                    EmailConfirmed = true
                };
                var result = await userManager.CreateAsync(admin, "Ministry@1234!");
                if (result.Succeeded)
                    await userManager.AddToRoleAsync(admin, AppRoles.MinistryAdmin);
            }
        }
    }
}