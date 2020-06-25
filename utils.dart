_onCameraPersionRequest(
    {Function onGranted,
    Function onAlreadyDenied,
    Function onJustDeny,
    Function onAndroidPermanentDenied}) {
  Permission.camera.status.then((value) {
    print('status: ' + value.toString());
    if (value.isUndetermined) {
      Permission.camera.request().then((value) {
        if (value.isDenied) {
          if (onJustDeny != null) onJustDeny();
        } else if (value.isGranted) {
          if (onGranted != null) onGranted();
        } else if (value.isPermanentlyDenied) {
          if (onAndroidPermanentDenied != null) onAndroidPermanentDenied();
        }
      });
    } else if (value.isDenied) {
      if (onAlreadyDenied != null) onAlreadyDenied();
    }
  });
}

showWarningDialog(BuildContext context, String content, String btnText,
    {String title}) {
  Widget alert;

  Widget _titleWidget = title != null
      ? Text(
          title,
          textAlign: TextAlign.start,
        )
      : null;

  if (Platform.isAndroid) {
    // If it has plenty of buttons, it will stack them on vertical way.
    // If title isn't supplied, height of this alert will smaller than the one has title.
    alert = AlertDialog(
      title: _titleWidget,
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
    // If title isn't supplied, height of this alert will smaller than the one has title.
    alert = CupertinoAlertDialog(
      title: _titleWidget,
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
            style: TextStyle(fontWeight: FontWeight.bold),
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
  );
}
