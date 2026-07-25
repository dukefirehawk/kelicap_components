# Example of using Material Components

## my-component.dart

```dart
@Component(
  selector: 'my-component',
  templateUrl: 'my-component.html',
  styleUrls: ['my-component.css'],
  directives: [
    DarkThemeDirective,
    MaterialButtonComponent,
    MaterialFabComponent,
    MaterialIconComponent,
  ],
  preserveWhitespace: true,
)
class MyComponent {
  String content = 'click me';
}
```

## my-component.html

```html
<h1>My Component</h1>

<div>
  <section class="button-panel">
    <h2>Custom text</h2>
    <material-button raised>{{content}}</material-button>
    <material-button raised class="blue">Colored {{content}}</material-button>
    <material-button raised disabled>Disabled {{content}}</material-button>
  </section>
</div>

```

## my-component.scss

```css

.button-panel {
  padding: 1em;
}

```

