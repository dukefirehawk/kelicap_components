/// Returns the link to the source of [path] in the repository at
/// [repositoryUrl], such as `https://github.com/<owner>/<repo>/blob/main`.
///
/// [path] is the path of a file in its package, after the package name, such
/// as `kelicap_components/lib/material_button/material_button.dart`, as the
/// gallery builders record it for documentation and demos. The package is
/// mapped to its directory in the repository: `kelicap_components` is in
/// `components`, and an example package, such as `material_button_example`,
/// is in `component_gallery/examples`. Another package is assumed to be in a
/// directory of its name.
///
/// Returns [repositoryUrl] if [path] has no package.
String sourceCodeLink(String repositoryUrl, String path) {
  final base = repositoryUrl.endsWith('/')
      ? repositoryUrl.substring(0, repositoryUrl.length - 1)
      : repositoryUrl;
  final slash = path.indexOf('/');
  if (slash <= 0) return base;
  final package = path.substring(0, slash);
  final directory = switch (package) {
    'kelicap_components' => 'components',
    _ when package.endsWith('_example') =>
      'component_gallery/examples/$package',
    _ => package,
  };
  return '$base/$directory${path.substring(slash)}';
}
