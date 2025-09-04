import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/user_details_form/user_details_form_widget.dart';
import 'user_details_page_widget.dart' show UserDetailsPageWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserDetailsPageModel extends FlutterFlowModel<UserDetailsPageWidget> {
  ///  Local state fields for this page.

  String genderData = 'Male';

  double? weightData = 0.0;

  int? heightData = 0;

  int? ageData = 0;

  ///  State fields for stateful widgets in this page.

  // Model for UserDetailsWidget.
  late UserDetailsFormModel userDetailsWidgetModel;

  @override
  void initState(BuildContext context) {
    userDetailsWidgetModel = createModel(context, () => UserDetailsFormModel());
  }

  @override
  void dispose() {
    userDetailsWidgetModel.dispose();
  }
}
