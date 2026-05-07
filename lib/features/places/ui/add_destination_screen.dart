import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models/place_model.dart';
import '../data/sources/places_local_source.dart';

/// Save a custom destination locally (negative id so it does not clash with API ids).
class AddDestinationScreen extends StatefulWidget {
  const AddDestinationScreen({super.key});

  @override
  State<AddDestinationScreen> createState() => _AddDestinationScreenState();
}

class _AddDestinationScreenState extends State<AddDestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final id = -DateTime.now().millisecondsSinceEpoch;
    final title = _titleCtrl.text.trim();
    var thumb = _imageCtrl.text.trim();
    var full = thumb;

    if (thumb.isEmpty) {
      thumb = 'https://picsum.photos/seed/custom${id.abs()}/240/200';
      full = 'https://picsum.photos/seed/custom${id.abs()}/800/520';
    } else if (!thumb.startsWith('http://') && !thumb.startsWith('https://')) {
      thumb = 'https://$thumb';
      full = thumb;
    }

    final place = PlaceModel(
      id: id,
      title: title,
      thumbnailUrl: thumb,
      url: full,
      albumId: 0,
    );

    await sl<PlacesLocalSource>().addUserDestination(place);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add destination')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Create a destination for your trips. It is saved on this device '
              'and appears at the top of Explore Places.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Lake Como weekend',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter a name';
                if (v.trim().length < 2) return 'Too short';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Photo URL (optional)',
                hintText: 'https://… Leave empty for an automatic image',
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_saving ? 'Saving…' : 'Save destination'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
