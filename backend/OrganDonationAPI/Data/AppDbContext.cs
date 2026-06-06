using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using OrganDonationAPI.Models;
namespace OrganDonationAPI.Data
{
    public class AppDbContext : IdentityDbContext<ApplicationUser>
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Donor> Donors { get; set; }
        public DbSet<Hospital> Hospitals { get; set; }
        public DbSet<DeceasedPatient> DeceasedPatients { get; set; }
        public DbSet<PatientNeed> PatientNeeds { get; set; }
        public DbSet<Donor> DonorRequests { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            modelBuilder.Entity<Hospital>().HasOne(h => h.User).WithOne().HasForeignKey<Hospital>(h => h.UserId).OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<Hospital>().HasIndex(h => h.UserId).IsUnique();
            // Unique على LicenseNumber — رقم ترخيص ما يتكرر
             modelBuilder.Entity<Hospital>().HasIndex(h => h.LicenseNumber).IsUnique();

            modelBuilder.Entity<PatientNeed>().HasOne(p => p.Hospital).WithMany(h => h.PatientNeeds).HasForeignKey(p => p.HospitalId).OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<Donor>().HasOne(d => d.User).WithOne().HasForeignKey<Donor>(d => d.UserId).OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<Donor>().HasIndex(d => d.UserId).IsUnique();
            modelBuilder.Entity<Donor>().HasIndex(d => d.NationalId).IsUnique();
            modelBuilder.Entity<DeceasedPatient>().HasOne(d => d.Hospital).WithMany().HasForeignKey(d => d.HospitalId).OnDelete(DeleteBehavior.Restrict);




        }
    }


}