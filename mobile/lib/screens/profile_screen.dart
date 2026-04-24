import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GarnishColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Welcome back,',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: GarnishColors.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.name,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: GarnishColors.textDark,
                ),
              ),
              const SizedBox(height: 32),

              // Account details
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: GarnishColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: GarnishColors.border),
                ),
                child: Column(
                  children: [
                    _DetailRow(label: 'Name', value: user.name),
                    const Divider(
                        height: 1, color: GarnishColors.border, indent: 16, endIndent: 16),
                    _DetailRow(label: 'Email', value: user.email),
                    const Divider(
                        height: 1, color: GarnishColors.border, indent: 16, endIndent: 16),
                    _DetailRow(
                      label: 'Email verified',
                      value: user.isEmailVerified ? 'Yes' : 'No',
                      valueColor: user.isEmailVerified
                          ? GarnishColors.green
                          : Colors.red.shade500,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Log out
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _confirmLogout(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: GarnishColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Log Out',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: GarnishColors.textMid,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GarnishColors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Log Out',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to log out?',
            style: GoogleFonts.dmSans(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style:
                    GoogleFonts.dmSans(color: GarnishColors.textMid)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Log Out',
                style: GoogleFonts.dmSans(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.logout();
      onLogout();
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: GarnishColors.textLight,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? GarnishColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
