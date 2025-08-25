import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hbitolar/providers/auth_provider.dart';
import 'package:hbitolar/services/storage_service.dart';
import 'package:hbitolar/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  bool _isEditingProfile = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (image == null) return;

      setState(() => _isUploadingPhoto = true);

      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser == null) return;

      final imageUrl = await _storageService.uploadProfileImage(
        File(image.path),
        authProvider.currentUser!.uid,
      );

      if (imageUrl != null) {
        await authProvider.updateUserProfile(
          authProvider.currentUser!.copyWith(
            photoUrl: imageUrl,
            updatedAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer upload da imagem: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    await authProvider.updateUserProfile(
      authProvider.currentUser!.copyWith(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        updatedAt: DateTime.now(),
      ),
    );

    setState(() => _isEditingProfile = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.currentUser;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Perfil',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Profile Photo
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: _isUploadingPhoto
                            ? const Center(child: CircularProgressIndicator())
                            : user.photoUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      user.photoUrl!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          _buildDefaultAvatar(user.name),
                                    ),
                                  )
                                : _buildDefaultAvatar(user.name),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            onPressed: _isUploadingPhoto ? null : _pickAndUploadImage,
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // User Stats
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Nível', '${user.level}'),
                        Container(
                          width: 1,
                          height: 40,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                        _buildStatColumn('XP Total', '${user.totalXp}'),
                        Container(
                          width: 1,
                          height: 40,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                        _buildStatColumn('Hábitos', '${(context.watch<AuthProvider>().currentUser?.totalXp ?? 0) > 0 ? 'Ativo' : 'Inativo'}'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Profile Form
                  if (_isEditingProfile) ...[
                    _buildEditForm(),
                  ] else ...[
                    _buildProfileInfo(user),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Menu Items
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Configurações de notificação em breve!')),
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.analytics_outlined,
                    title: 'Relatórios',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Relatórios em breve!')),
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Ajuda',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Central de ajuda em breve!')),
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'Sobre',
                    onTap: () => _showAboutDialog(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initials = name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join();
    
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nome',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Bio',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  final user = context.read<AuthProvider>().currentUser!;
                  _nameController.text = user.name;
                  _bioController.text = user.bio ?? '';
                  setState(() => _isEditingProfile = false);
                },
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileInfo(user) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Informações Pessoais',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _isEditingProfile = true),
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Nome',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                user.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Email',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (user.bio != null && user.bio!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Bio',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  user.bio!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre o Habitracker'),
        content: const Text(
          'Habitracker é o seu parceiro diário para construir e manter hábitos saudáveis, '
          'transformando a jornada de autodesenvolvimento em uma experiência recompensadora e divertida.\n\n'
          'Versão 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}