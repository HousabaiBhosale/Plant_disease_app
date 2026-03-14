import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scanner_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHealthTab(),
          _buildCommunityTab(),
          _buildLibraryTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plant Doc AI',
            style: GoogleFonts.outfit(
              color: const Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            'India • 28°C',
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: Colors.black87),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.favorite, Icons.favorite_border, 'Health'),
          _buildNavItem(1, Icons.forum, Icons.forum_outlined, 'Community'),
          const SizedBox(width: 40), // Space for FAB
          _buildNavItem(2, Icons.auto_stories, Icons.auto_stories_outlined, 'Library'),
          _buildNavItem(3, Icons.person, Icons.person_outline, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
            ),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScannerPage()),
        );
      },
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 4,
      child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMyCropsSection(),
          const SizedBox(height: 24),
          _buildMainActionCard(),
          const SizedBox(height: 24),
          Text(
            'Recommended Advice',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildAdviceGrid(),
          const SizedBox(height: 80), // FAB spacer
        ],
      ),
    );
  }

  Widget _buildMyCropsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Crops',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Edit', style: TextStyle(color: Color(0xFF2E7D32))),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCropIcon('Tomato', '🍅'),
              _buildCropIcon('Potato', '🥔'),
              _buildCropIcon('Rice', '🌾'),
              _buildCropIcon('Wheat', '🌾'),
              _buildAddCropIcon(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCropIcon(String name, String emoji) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(height: 8),
          Text(name, style: GoogleFonts.outfit(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildAddCropIcon() {
    return Container(
      width: 80,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
            ),
            child: const Icon(Icons.add, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 8),
          Text('Add', style: GoogleFonts.outfit(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildMainActionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/leaf.png'),
          opacity: 0.1,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety, color: Colors.white, size: 40),
          const SizedBox(height: 16),
          Text(
            'Heal your crop',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo of your crop to diagnose the issue.',
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerPage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('TAKE A PHOTO', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.8,
      children: [
        _buildSimplifiedAdviceCard('Early Blight', 'Tomato', 'https://images.unsplash.com/photo-1592321675774-3de57f3ee0dc?q=80&w=400&fit=crop'),
        _buildSimplifiedAdviceCard('Late Blight', 'Potato', 'https://images.unsplash.com/photo-1518977676601-b53f02bad67b?q=80&w=400&fit=crop'),
      ],
    );
  }

  Widget _buildSimplifiedAdviceCard(String title, String crop, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Image.network(imageUrl, height: 100, width: double.infinity, fit: BoxFit.cover, 
              errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crop, style: GoogleFonts.outfit(color: const Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Placeholder Tabs ---

  Widget _buildCommunityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Top Agri Discussions', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildPostCard('Ramesh Kumar', 'How can I increase my wheat yield this season?', '2 hours ago'),
        _buildPostCard('Anita Devi', 'Suggest any organic fertilizer for Tomato.', '5 hours ago'),
      ],
    );
  }

  Widget _buildPostCard(String user, String text, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.person, color: Color(0xFF2E7D32))),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(text, style: const TextStyle(fontSize: 15)),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.favorite_border, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('Like', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 24),
                const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('Comment', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryTab() {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildLibraryCategory('Potato', '🥔'),
        _buildLibraryCategory('Tomato', '🍅'),
        _buildLibraryCategory('Rice', '🌾'),
        _buildLibraryCategory('Wheat', '🌾'),
        _buildLibraryCategory('Corn', '🌽'),
        _buildLibraryCategory('Soybean', '🫛'),
      ],
    );
  }

  Widget _buildLibraryCategory(String name, String emoji) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.person, size: 60, color: Color(0xFF2E7D32))),
          const SizedBox(height: 16),
          Text('Farmer Name', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Location: India'),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: const Text('Edit Profile')),
        ],
      ),
    );
  }
}
