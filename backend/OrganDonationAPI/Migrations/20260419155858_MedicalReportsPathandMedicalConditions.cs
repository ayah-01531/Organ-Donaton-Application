using Microsoft.EntityFrameworkCore.Migrations;
using OrganDonationAPI.Data;

#nullable disable

namespace OrganDonationAPI.Migrations
{
    /// <inheritdoc />
    public partial class MedicalReportsPathandMedicalConditions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "MedicalConditions",
                table: "Donors",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MedicalReportsPath",
                table: "Donors",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "MedicalConditions",
                table: "Donors");

            migrationBuilder.DropColumn(
                name: "MedicalReportsPath",
                table: "Donors");
        }
    }
}
