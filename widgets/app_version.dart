
// Usually go within Scaffold's bottomNavigationBar.
SafeArea(
          top: false,
          child: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (_, ss) {
              final data = ss?.data;
              return Text(
                data == null ? '' : '${data.version}.${data.buildNumber}',
                textAlign: TextAlign.center,
              );
            },
          ))