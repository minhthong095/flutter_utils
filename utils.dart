bool phoneNumberMatch(String phone) {
  return RegExp(r"^[0-9]{10}$").hasMatch(phone);
}

bool emailMatch(String email) {
  return RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(email);
}

_fullAddress(String address, String ward, String district, String province) {
  final _adress = address ?? '';
  final _ward = ward == null && ward.isEmpty ? '' : ' $ward,';
  final _district = district == null && district.isEmpty ? '' : ' $district,';
  final _province = province == null && province.isEmpty ? '' : ' $province,';
  return '$_adress$_ward$_district$_province';
}

_onCameraPersionRequest(
    {Function onGranted,
    Function onAlreadyDenied,
    Function onJustDeny,
    Function onAndroidPermanentDenied}) {
  Permission.camera.status.then((value) {
    print('status: ' + value.toString());
    if (value.isUndetermined) {
      Permission.camera.request().then((value) {
        if (value.isDenied && onJustDeny != null) {
          onJustDeny();
        } else if (value.isGranted && onGranted != null) {
          onGranted();
        } else if (value.isPermanentlyDenied &&
            onAndroidPermanentDenied != null) {
          onAndroidPermanentDenied();
        }
      });
    } else if (value.isDenied && onAlreadyDenied != null) {
      onAlreadyDenied();
    } else if (value.isGranted && onGranted != null) {
      onGranted();
    }
  });
}

showWarningDialog(BuildContext context, String content, String btnText,
    {String title, Function onCloseDialog}) {
  Widget alert;

  Widget _titleWidget({TextAlign textAlign = TextAlign.start}) => title != null
      ? Text(
          title,
          textAlign: textAlign,
        )
      : null;

  if (content != null && content.isNotEmpty) {
    if (Platform.isAndroid) {
      // If it has plenty of buttons, it will stack them on vertical way.
      // If title isn't supplied, height of this alert will smaller than the one has title.
      alert = AlertDialog(
        title: _titleWidget(),
        content: Text(
          content,
          textAlign: TextAlign.start,
        ),
        actions: [
          FlatButton(
            child: Text(btnText),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    } else {
      // Almost similiar with Cupertino style.
      // If title isn't supplied, height of this alert will smaller than the one has title.
      alert = CupertinoAlertDialog(
        title: Padding(
          padding: EdgeInsets.only(
            bottom: 10,
          ),
          child: _titleWidget(textAlign: TextAlign.center),
        ),
        content: Text(
          content,
          textAlign: TextAlign.start,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              btnText,
            ),
          )
        ],
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    ).then((value) {
      if (onCloseDialog != null) {
        onCloseDialog();
      }
    });
  }
}
