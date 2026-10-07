// =============================================================
// ChefUnitPlus - Dashboard Utilisateur PROFESSIONNEL
// Formations + Videos + Actualites + Communiques
// =============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/user_avatar.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  bool _loading = false;
  List<Map<String, dynamic>> _news = [];
  List<Map<String, dynamic>> _videos = [];

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _loading = true);
    // TODO: Charger depuis l'API
    // Pour l'instant, donnÃ©es de dÃ©mo
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _loading = false;
      _news = [
        {'title': 'Camp national 2026', 'category': 'actualite',
         'content': 'Le grand camp national aura lieu en decembre 2026 a Kinshasa.'},
        {'title': 'Ceremonie de passage', 'category': 'communique',
         'content': 'Les ceremonies de passage se derouleront le 15 octobre.'},
      ];
      _videos = [
        {'title': 'Activites du quartier Gombe', 'quartier': 'Gombe'},
        {'title': 'Camp de formation', 'quartier': 'Limete'},
        {'title': 'Ceremonie officielle', 'quartier': 'Kintambo'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ChefUnitPlus'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadContent,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.mauve, AppColors.mauveDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      UserAvatar(
                        radius: 28,
                        photoUrl: auth.currentUser?.photoUrl,
                        initials: (auth.currentUser?.fullName ?? 'U')[0].toUpperCase(),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour ${auth.currentUser?.fullName ?? ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Bienvenue sur ChefUnitPlus',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section Formations
            _sectionHeader('Formations disponibles', Icons.school),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _formationCard('Scoutisme Avance', '5 modules', '5000 FC'),
                  _formationCard('Leadership', '3 modules', '3000 FC'),
                  _formationCard('Secourisme', '4 modules', '4000 FC'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section Videos
            _sectionHeader('Videos des quartiers', Icons.video_library),
            if (_loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ))
            else
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _videos.length,
                  itemBuilder: (_, i) => _videoCard(_videos[i]),
                ),
              ),

            const SizedBox(height: 20),

            // Section Actualites
            _sectionHeader('Actualites scoutes', Icons.newspaper),
            if (!_loading)
              ..._news.map((n) => _newsCard(n)),

            const SizedBox(height: 20),

            // Actions rapides
            _sectionHeader('Actions rapides', Icons.bolt),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _actionTile(Icons.person_outline, 'Mon profil',
                      () => Navigator.pushNamed(context, AppRoutes.profile)),
                  _actionTile(Icons.logout, 'Se deconnecter', () async {
                    await auth.logout();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (route) => false);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mauve, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formationCard(String title, String modules, String price) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mauveSoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(modules, style: const TextStyle(fontSize: 10, color: AppColors.mauve)),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: const TextStyle(
                color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mauve,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: const Size(0, 30),
                ),
                child: const Text("S'inscrire", style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _videoCard(Map<String, dynamic> video) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 90,
            decoration: const BoxDecoration(
              color: AppColors.mauveSoft,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Center(
              child: Icon(Icons.play_circle_fill, size: 40, color: AppColors.mauve),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              video['title'] ?? '',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _newsCard(Map<String, dynamic> news) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.mauveSoft,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  (news['category'] ?? 'actualite').toUpperCase(),
                  style: const TextStyle(fontSize: 9, color: AppColors.mauve, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(news['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(news['content'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.mauve),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}