import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'cover_design.dart';

const _ink = Color(0xFF173B43);
const _gold = Color(0xFFC89543);
const _line = Color(0xFFDDD5C7);
const _formBorder = Color(0xFFE8CDA6);
const _formSurface = Color(0xFFFFFCF7);

Future<CoverDesign?> showCoverDesignForm(
  BuildContext context, {
  required String creator,
  CoverDesign? design,
}) => showDialog<CoverDesign>(
  context: context,
  builder: (_) => _CoverDesignForm(creator: creator, design: design),
);

class _CoverDesignForm extends StatefulWidget {
  const _CoverDesignForm({required this.creator, this.design});

  final String creator;
  final CoverDesign? design;

  @override
  State<_CoverDesignForm> createState() => _CoverDesignFormState();
}

class _CoverDesignFormState extends State<_CoverDesignForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.design?.title);
  late final _author = TextEditingController(text: widget.design?.author);
  late final _year = TextEditingController(text: widget.design?.year);
  Uint8List? _imageBytes;
  bool _isDraft = false;
  bool _pickingImage = false;

  @override
  void initState() {
    super.initState();
    _imageBytes = widget.design?.imageBytes;
    _isDraft = widget.design?.isDraft ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _uploadCover() async {
    setState(() => _pickingImage = true);
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Unable to upload cover image: ${error.message ?? error.code}',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  void _save({required bool asDraft}) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Upload the cover page to continue.')),
        );
      return;
    }

    Navigator.of(context).pop(
      CoverDesign(
        title: _title.text.trim(),
        author: _author.text.trim(),
        year: _year.text.trim(),
        creator: widget.creator,
        color: widget.design?.color ?? _gold,
        imageBytes: _imageBytes,
        isDraft: asDraft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680, maxHeight: 700),
      child: Container(
        decoration: BoxDecoration(
          color: _formSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _formBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1472552D),
              blurRadius: 18,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(19, 12, 18, 9),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFF8EA),
                        border: Border.all(color: _formBorder),
                      ),
                      child: const Icon(
                        Icons.book_outlined,
                        color: _gold,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 19),
                    Expanded(
                      child: Text(
                        widget.design == null ? 'Add Cover' : 'Edit Cover',
                        style: const TextStyle(
                          color: _ink,
                          fontFamily: 'Georgia',
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      height: 32,
                      child: IconButton(
                        tooltip: 'Close',
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: _gold, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                _uploadArea(),
                if (_imageBytes != null) ...[
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _imageBytes!,
                      height: 145,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                _detailField(
                  controller: _title,
                  label: 'Book name',
                  icon: Icons.menu_book_outlined,
                  validator: _required,
                  capitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 5),
                _detailField(
                  controller: _author,
                  label: 'Author name',
                  icon: Icons.person_outline,
                  validator: _required,
                  capitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 5),
                _detailField(
                  controller: _year,
                  label: 'Year made',
                  icon: Icons.calendar_month_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final year = int.tryParse(value?.trim() ?? '');
                    if (year == null ||
                        year < 1 ||
                        year > DateTime.now().year) {
                      return 'Enter a valid year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 9),
                const Divider(height: 1, color: _line),
                const SizedBox(height: 8),
                _actions(context),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _uploadArea() => CustomPaint(
    foregroundPainter: const _DashedBorderPainter(),
    child: Material(
      color: const Color(0xFFFFF9EF),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: _pickingImage ? null : _uploadCover,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          height: 49,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _pickingImage
                    ? Icons.hourglass_top
                    : Icons.upload_file_outlined,
                color: _gold,
                size: 23,
              ),
              const SizedBox(width: 11),
              Text(
                _pickingImage
                    ? 'Loading cover...'
                    : _imageBytes == null
                    ? 'Upload Cover Page'
                    : 'Change Cover Page',
                style: const TextStyle(
                  color: _ink,
                  fontFamily: 'Georgia',
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _detailField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    textCapitalization: capitalization,
    validator: validator,
    style: const TextStyle(color: _ink, fontSize: 12),
    decoration: InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Color(0xFF555B5B), fontSize: 11),
      prefixIcon: Icon(icon, color: _gold, size: 17),
      prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 28),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: _formBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: _formBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: _gold),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    ),
  );

  Widget _actions(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 480;
      return Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: _ink,
                minimumSize: const Size.fromHeight(37),
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => _save(asDraft: !_isDraft),
              style: TextButton.styleFrom(
                foregroundColor: _ink,
                minimumSize: const Size.fromHeight(37),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                textStyle: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(_isDraft ? 'Publish Cover' : 'Save as Draft'),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => _save(asDraft: _isDraft),
                style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  minimumSize: Size(compact ? 0 : 140, 37),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(
                  widget.design == null ? 'Add Cover' : 'Save Changes',
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _formBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(9)));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 4).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 7;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
