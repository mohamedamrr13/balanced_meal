import 'package:flutter/material.dart';

class CustomDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? color;

  const CustomDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });
}

class AppCustomDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hintText;
  final T? value;
  final List<CustomDropdownItem<T>> items;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final Widget? prefixIcon;
  final double borderRadius;
  final Color? fillColor;
  final double maxHeight;

  const AppCustomDropdown({
    super.key,
    this.label,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.borderRadius = 12,
    this.fillColor,
    this.maxHeight = 200,
  });

  @override
  State<AppCustomDropdown<T>> createState() => _AppCustomDropdownState<T>();
}

class _AppCustomDropdownState<T> extends State<AppCustomDropdown<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<Color?> _borderColorAnimation;

  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _hasError = false;
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _borderColorAnimation = ColorTween(
      begin: Colors.grey[300],
      end: Theme.of(context).colorScheme.primary,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_isOpen) {
      _openDropdown();
    }
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (!widget.enabled || _isOpen) return;

    setState(() {
      _isOpen = true;
    });
    _animationController.forward();
    _createOverlay();
  }

  void _closeDropdown() {
    if (!_isOpen) return;

    setState(() {
      _isOpen = false;
    });
    _animationController.reverse();
    _removeOverlay();
  }

  void _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 16, // Left padding from screen edge
        right: 16, // Right padding from screen edge
        top: offset.dy + size.height + 8,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          shadowColor: Colors.black.withOpacity(0.1),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: _animation.value,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: widget.maxHeight,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        final isSelected = item.value == _selectedValue;

                        return InkWell(
                          onTap: () => _selectItem(item),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                if (item.icon != null) ...[
                                  Icon(
                                    item.icon,
                                    size: 20,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : (item.color ?? Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey[800],
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectItem(CustomDropdownItem<T> item) {
    setState(() {
      _selectedValue = item.value;
    });
    widget.onChanged?.call(item.value);
    _closeDropdown();
  }

  String _getDisplayText() {
    if (_selectedValue == null) {
      return widget.hintText ?? '';
    }
    final selectedItem = widget.items.firstWhere(
      (item) => item.value == _selectedValue,
      orElse: () => widget.items.first,
    );
    return selectedItem.label;
  }

  Widget? _getDisplayIcon() {
    if (_selectedValue == null) return null;
    final selectedItem = widget.items.firstWhere(
      (item) => item.value == _selectedValue,
      orElse: () => widget.items.first,
    );
    return selectedItem.icon != null
        ? Icon(
            selectedItem.icon,
            size: 20,
            color: selectedItem.color ?? Theme.of(context).colorScheme.primary,
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: _isOpen
                  ? theme.colorScheme.primary
                  : (_hasError ? Colors.red[600] : Colors.grey[700]),
            ),
            child: Text(widget.label!),
          ),
          const SizedBox(height: 8),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    boxShadow: _isOpen && !_hasError
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon != null ? 12 : 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: widget.fillColor ??
                          (widget.enabled
                              ? (_isOpen
                                  ? theme.colorScheme.primary.withOpacity(0.05)
                                  : Colors.grey[50])
                              : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: _isOpen
                            ? (_borderColorAnimation.value ??
                                theme.colorScheme.primary)
                            : Colors.grey[300]!,
                        width: _isOpen ? 2 : 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (widget.prefixIcon != null) ...[
                          widget.prefixIcon!,
                          const SizedBox(width: 12),
                        ],
                        if (_getDisplayIcon() != null) ...[
                          _getDisplayIcon()!,
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            _getDisplayText(),
                            style: _selectedValue == null
                                ? TextStyle(
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w400,
                                  )
                                : theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isOpen ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: _isOpen
                                ? theme.colorScheme.primary
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
