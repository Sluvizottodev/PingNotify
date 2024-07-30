import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Service/TagProvider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/routes.dart';

class AppBarPrincipal extends StatelessWidget implements PreferredSizeWidget {
  final Function fetchNotifications;

  const AppBarPrincipal({required this.fetchNotifications});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Notificações', style: TextStyle(color: Colors.white)),
      backgroundColor: TColors.secondaryColor,
      elevation: 4,
      actions: [
        IconButton(
          icon: Icon(Icons.slow_motion_video, color: Colors.white),
          onPressed: () {
            // Implementar a navegação para a página de configurações
            //Navigator.pushNamed(context, PageRoutes.cursos);
          },
        ),
        IconButton(
          icon: Icon(Icons.tag, color: Colors.white),
          onPressed: () async {
            final selectedTags = await Navigator.pushNamed(context, PageRoutes.tagSelection) as List<String>?;
            if (selectedTags != null) {
              Provider.of<TagProvider>(context, listen: false).setSelectedTags(selectedTags.toSet());
              await fetchNotifications();
            }
          },
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }
}
