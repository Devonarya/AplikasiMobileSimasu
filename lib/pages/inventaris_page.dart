import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';

const kLogoPath = 'assets/images/simasu_mark.png';
void main() => runApp(const SimasuApp());

class SimasuApp extends StatelessWidget {
  const SimasuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMASU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: _Palette.primary,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _Palette.primary, width: 1.6),
          ),
        ),
      ),
      home: const AuthPage(),
    );
  }
}

class _Palette {
  static const primary = Color(0xFF2F6E3E);
  static const primaryDark = Color(0xFF255733);
  static const lightMint = Color(0xFFEFF6F1);
  static const lightMint2 = Color(0xFFE2EFE7);
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isRegister = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _HeaderGradient(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const _Logo(),
                  const SizedBox(height: 12),
                  Text(
                    'S I M A S U',
                    style: TextStyle(
                      letterSpacing: 6,
                      color: _Palette.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kelola Inventaris &\nRuangan Masjid',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Aplikasi modern bernuansa Islami untuk memudahkan pencatatan inventaris dan peminjaman ruangan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _AuthCard(
                        isRegister: isRegister,
                        onToggle: (val) => setState(() => isRegister = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '© 2025 Takmir Masjid Al-Barokah.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(48),
        bottomRight: Radius.circular(48),
      ),
      child: Container(
        height: 260,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6FAF7), _Palette.lightMint],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            kLogoPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            semanticLabel: 'Logo SIMASU',
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatefulWidget {
  final bool isRegister;
  final ValueChanged<bool> onToggle;

  const _AuthCard({required this.isRegister, required this.onToggle});

  @override
  State<_AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<_AuthCard> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  static const _kStaticEmail = 'admin@gmail.com';
  static const _kStaticPass = 'admin123';

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = widget.isRegister;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _Palette.primary.withOpacity(0.09),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SegmentedTabs(
            activeRight: isRegister,
            leftText: 'Masuk',
            rightText: 'Daftar',
            onTapLeft: () => widget.onToggle(false),
            onTapRight: () => widget.onToggle(true),
          ),
          const SizedBox(height: 18),
          Text('Email', style: _labelStyle),
          const SizedBox(height: 8),
          TextField(
            controller: _email,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'nama@domain.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Text('Kata Sandi', style: _labelStyle),
          const SizedBox(height: 8),
          TextField(
            controller: _pass,
            focusNode: _passFocus,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Minimal 6 karakter',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          if (isRegister) ...[
            const SizedBox(height: 16),
            Text('Konfirmasi Kata Sandi', style: _labelStyle),
            const SizedBox(height: 8),
            TextField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Ulangi kata sandi',
                prefixIcon: Icon(Icons.lock_reset_outlined),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => isRegister ? _onRegister() : _onLogin(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _Palette.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 4,
                shadowColor: _Palette.primaryDark.withOpacity(0.4),
              ),
              child: Text(
                isRegister ? 'Daftar' : 'Masuk',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Wrap(
              spacing: 4,
              children: [
                Text(
                  isRegister ? 'Sudah memiliki akun?' : 'Belum punya akun?',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                InkWell(
                  onTap: () => widget.onToggle(!isRegister),
                  child: Text(
                    isRegister ? 'Masuk di sini' : 'Daftar di sini',
                    style: const TextStyle(
                      color: _Palette.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Dengan masuk, Anda menyetujui tata tertib dan peraturan pengelolaan fasilitas masjid.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _onLogin() {
    final email = _email.text.trim();
    final pass = _pass.text;

    if (email == _kStaticEmail && pass == _kStaticPass) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MasjidApp()));
    } else {
      _pass.clear();
      _emailFocus.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau kata sandi salah.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onRegister() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Masih belum nyimpen data apa apa.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  TextStyle get _labelStyle =>
      TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade800);
}

class _SegmentedTabs extends StatelessWidget {
  final bool activeRight;
  final String leftText;
  final String rightText;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;

  const _SegmentedTabs({
    required this.activeRight,
    required this.leftText,
    required this.rightText,
    required this.onTapLeft,
    required this.onTapRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: _Palette.lightMint2,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              text: leftText,
              active: !activeRight,
              onTap: onTapLeft,
            ),
          ),
          Expanded(
            child: _TabPill(
              text: rightText,
              active: activeRight,
              onTap: onTapRight,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _TabPill({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: active ? Colors.white : _Palette.primary,
        ),
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: active ? _Palette.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: active
            ? [
                BoxShadow(
                  color: _Palette.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}
