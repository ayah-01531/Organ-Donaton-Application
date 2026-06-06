using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace OrganDonationAPI.Migrations
{
    /// <inheritdoc />
    public partial class donerTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DateOfDeath",
                table: "Donor",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DeathCertificatePath",
                table: "Donor",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DateOfDeath",
                table: "Donor");

            migrationBuilder.DropColumn(
                name: "DeathCertificatePath",
                table: "Donor");
        }
    }
}
