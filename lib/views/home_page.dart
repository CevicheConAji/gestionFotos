import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_page_controller.dart';
import '../services/upload_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomePageController>();
    final photos =
        controller.photos
            .where(
              (p) =>
                  p.fileName.toLowerCase().contains(_searchText.toLowerCase()),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galería'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            tooltip: 'Subir seleccionadas',
            onPressed: () {
              _showUploadDialog(context);
            },
          ),

          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar seleccionadas',
            onPressed: () => controller.deleteSelected(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (text) {
                setState(() {
                  _searchText = text;
                });
              },
            ),
          ),
          Expanded(
            child:
                photos.isEmpty
                    ? const Center(child: Text('No hay imágenes.'))
                    : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        return GestureDetector(
                          onLongPress: () => controller.toggleSelection(photo),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(photo.file, fit: BoxFit.cover),
                              if (photo.isSelected)
                                Container(
                                  color: Colors.black.withAlpha(128),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar desde galería',
        onPressed: () => controller.pickImages(),
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    final TextEditingController folderController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Nombre de la carpeta'),
          content: TextField(
            controller: folderController,
            decoration: const InputDecoration(labelText: 'Ej: pedido_0324'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Subir'),
              onPressed: () async {
                final folderName = folderController.text.trim();
                if (folderName.isEmpty) return;

                final controller = context.read<HomePageController>();
                final selected = controller.photos;

                if (selected.isEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⚠️ No hay imágenes seleccionadas'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                Navigator.pop(context); // cerrar el diálogo

                final success = await UploadService.uploadPhotosInOrder(
                  selected,
                  folderName: folderName,
                );

                controller.clearSelection();
                controller.clearPhotos();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '✅ Carpeta "$folderName" subida con éxito'
                          : '⚠️ Error al subir una o más imágenes en "$folderName"',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
