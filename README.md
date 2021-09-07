# koha-plugin-rapidill
This plugin provides Koha API routes enabling access to the RapidILL API. It is used in conjunction with the [RapidILL ILL backend](https://github.com/PTFS-Europe/koha-ill-rapidill) but it can be used in isolation if a authenticated JSON API to RapidILL is required.

This is a plugin for [Koha](https://koha-community.org/) that allows you to make queries to the [RapidILL API](https://rapid.exlibrisgroup.com/rapid5api/apiservice.asmx?wsdl) via a locally provided JSON API

## Getting Started

This plugin requires the following Perl modules:

[XML::Compile](https://metacpan.org/pod/XML::Compile)

[XML::Compile::SOAP]()

[XML::Compile::WSDL11](https://metacpan.org/pod/XML::Compile::WSDL11)

[XML::Compile::SOAP11](https://metacpan.org/pod/XML::Compile::SOAP11)

[XML::Compile::Transport::SOAPHTTP](https://metacpan.org/dist/XML-Compile-SOAP/view/lib/XML/Compile/Transport/SOAPHTTP.pod)

[JSON::Validator](https://metacpan.org/pod/JSON::Validator)

Download this plugin by downloading the latest release .kpz file from the [releases page](https://github.com/PTFS-Europe/koha-plugin-rapidill/releases).

The plugin system needs to be turned on by a system administrator.

To set up the Koha plugin system you must first make some changes to your install.

Change `<enable_plugins>0<enable_plugins>` to `<enable_plugins>1</enable_plugins>` in your `koha-conf.xml` file
Confirm that the path to `<pluginsdir>` exists, is correct, and is writable by the web server.
Restart your webserver.
Once set up is complete you will need to alter your `UseKohaPlugins` system preference.
Finally, on the "Koha Administration" page you will see the "Manage Plugins" option, select this to access the Plugins page.

### Installing

Once your Koha has plugins turned on, as detailed above, installing the plugin is then a case of selecting the "Upload plugin" 
button on the Plugins page and navigating to the .kpz file you downloaded

### Configuration

**The plugin requires configuration prior to usage**. To configure the plugin, select the "Actions" button listed by the plugin in the "Plugins" page, then select "Configure". On the configure page, you are required to supply your RapidILL API credentials, then click "Save configuration"



## Authors

* Andrew Isherwood
