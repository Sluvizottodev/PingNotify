import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Service/TagProvider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/routes.dart';

class AppBarPrincipal extends StatelessWidget implements PreferredSizeWidget {
  final Function fetchNotifications;
  final bool highlightTags;

  const AppBarPrincipal({
    required this.fetchNotifications,
    this.highlightTags = false,
  });

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
            Navigator.pushNamed(context, PageRoutes.cursos);
          },
        ),
        IconButton(
          icon: highlightTags
              ? Container(
                  padding:
                      EdgeInsets.all(8), // Espaçamento entre o ícone e a borda
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: TColors.errors, width: 2), // Borda circular
                  ),
                  child: Icon(Icons.tag, color: TColors.textWhite),
                )
              : Icon(Icons.tag, color: Colors.white),
          onPressed: () async {
            final selectedTags =
                await Navigator.pushNamed(context, PageRoutes.tagSelection)
                    as List<String>?;
            if (selectedTags != null) {
              Provider.of<TagProvider>(context, listen: false)
                  .setSelectedTags(selectedTags.toSet());
              await fetchNotifications();
            }
          },
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }
}
