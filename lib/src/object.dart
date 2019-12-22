import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';
import 'scene.dart';
import 'mesh.dart';

class Object {
  Object({
    Vector3 position,
    Vector3 rotation,
    Vector3 scale,
    this.name,
    this.mesh,
    this.scene,
    this.parent,
    this.children,
    String fileName,
  }) {
    if (position != null) position.copyInto(this.position);
    if (rotation != null) rotation.copyInto(this.rotation);
    if (scale != null) scale.copyInto(this.scale);
    updateTransform();
    this.mesh = mesh ?? Mesh();
    this.children = children ?? List<Object>();
    for (Object child in this.children) {
      child.parent = this;
    }

    // load mesh from obj file
    if (fileName != null) {
      loadObj(fileName).then((List<Mesh> meshes) {
        if (meshes.length == 1) {
          mesh = meshes[0];
        } else if (meshes.length > 1) {
          // multiple objects
          for (Mesh mesh in meshes) {
            add(Object(name: mesh.name, mesh: mesh, scene: scene));
          }
        }
        scene?.objectCreated(this);
      });
    } else {
      scene?.objectCreated(this);
    }
  }

  /// The local position of this object relative to the parent. Default is Vector3(0.0, 0.0, 0.0). updateTransform after you change the value.
  final Vector3 position = Vector3(0.0, 0.0, 0.0);

  /// The local rotation of this object relative to the parent. Default is Vector3(0.0, 0.0, 0.0). updateTransform after you change the value.
  final Vector3 rotation = Vector3(0.0, 0.0, 0.0);

  /// The local scale of this object relative to the parent. Default is Vector3(1.0, 1.0, 1.0). updateTransform after you change the value.
  final Vector3 scale = Vector3(1.0, 1.0, 1.0);

  /// The name of this object.
  String name;

  /// The scene of this object.
  Scene scene;

  /// The parent of this object.
  Object parent;

  /// The children of this object.
  List<Object> children;

  /// The mesh of this object
  Mesh mesh;

  /// The transformation of the object in the scene, including position, rotation, and scaling.
  final Matrix4 transform = Matrix4.identity();

  void updateTransform() {
    final Matrix4 m = Matrix4.compose(position, Quaternion.euler(radians(rotation.y), radians(rotation.x), radians(rotation.z)), scale);
    transform.setFrom(m);
  }

  /// Add a child
  void add(Object object) {
    assert(object != this);
    object.scene = scene;
    object.parent = this;
    children.add(object);
  }

  /// Find a child matching the name
  Object find(Pattern name) {
    for (Object child in children) {
      if ((name as RegExp).hasMatch(child.name)) return child;
      final Object result = child.find(name);
      if (result != null) return result;
    }
    return null;
  }
}
