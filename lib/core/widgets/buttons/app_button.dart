import 'package:videocalling/core/config/app_imports.dart';

class CustomButton extends StatelessWidget {
  VoidCallback onTap;
  String btnText;
  EdgeInsetsGeometry? margin;
  TextStyle? textStyle;
  IconData? icon;
  Color? backgroundColor;

  CustomButton({
    super.key,
    required this.onTap,
    required this.btnText,
    this.margin,
    this.textStyle,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: margin ?? const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: backgroundColor != null
                    ? [backgroundColor!, backgroundColor!]
                    : [
                        AppColors.color1,
                        AppColors.color1.withOpacity(0.9),
                      ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (backgroundColor ?? AppColors.color1).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  btnText,
                  style: textStyle ??
                      TextStyle(
                        fontFamily: AppFontStyleTextStrings.medium,
                        color: AppColors.WHITE,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButtonExpanded extends StatelessWidget {
  VoidCallback onTap;
  String btnText;
  IconData? icon;
  Color? backgroundColor;
  double? width;

  CustomButtonExpanded({
    super.key,
    required this.onTap,
    required this.btnText,
    this.icon,
    this.backgroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 48,
          width: width ?? Get.width / 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: backgroundColor != null
                  ? [backgroundColor!, backgroundColor!]
                  : [
                      AppColors.color1,
                      AppColors.color1,
                    ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (backgroundColor ?? AppColors.color1).withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                btnText,
                style: TextStyle(
                  color: AppColors.WHITE,
                  fontSize: 15,
                  fontFamily: AppFontStyleTextStrings.medium,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
