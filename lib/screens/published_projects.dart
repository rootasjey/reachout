import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rootasjey/components/project_card.dart';
import 'package:rootasjey/components/sliver_empty_view.dart';
import 'package:rootasjey/router//route_names.dart';
import 'package:rootasjey/router//router.dart';
import 'package:rootasjey/state/user_state.dart';
import 'package:rootasjey/types/project.dart';

class PublishedProjects extends StatefulWidget {
  @override
  _PublishedProjectsState createState() => _PublishedProjectsState();
}

class _PublishedProjectsState extends State<PublishedProjects> {
  final projectsList = List<Project>();
  final limit = 10;

  bool hasNext = true;
  bool isLoading = false;
  var lastDoc;

  @override
  void initState() {
    super.initState();
    initAndCheck();
  }

  void initAndCheck() async {
    final result = await checkAuth();
    if (!result) { return; }

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() {
    if (!isLoading && projectsList.isEmpty) {
      return SliverEmptyView();
    }

    return projectsGrid();
  }

  Widget projectsGrid() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final project = projectsList.elementAt(index);

          return ProjectCard(
            onTap: () async {
              FluroRouter.router.navigateTo(
                context,
                ProjectRoute.replaceFirst(':projectId', project.id),
              );
            },
            popupMenuButton: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    showDeleteDialog(index);
                    break;
                  case 'edit':
                    goToEditPage(project);
                    break;
                  case 'unpublish':
                    unpublish(index);
                    break;
                  default:
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text(
                      'Edit',
                    ),
                  ),
                ),

                const PopupMenuItem(
                  value: 'unpublish',
                  child: ListTile(
                    leading: Icon(Icons.public_off_sharp),
                    title: Text(
                      'Unpublish',
                    ),
                  ),
                ),

                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text(
                      'Delete',
                    ),
                  ),
                ),
              ],
            ),
            project: project,
          );
        },
        childCount: projectsList.length,
      ),
    );
  }

  void showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Are you sure?"
          ),
          content: SingleChildScrollView(
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "This action is irreversible.",
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => FluroRouter.router.pop(context),
              child: Text(
                'CANCEL',
                textAlign: TextAlign.end,
              ),
            ),

            TextButton(
              onPressed: () {
                FluroRouter.router.pop(context);
                delete(index);
              },
              child: Text(
                'DELETE',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  Future<bool> checkAuth() async {
    try {
      final userAuth = await userState.userAuth;
      if (userAuth != null) { return true; }

      FluroRouter.router.navigateTo(context, SigninRoute);
      return false;

    } catch (error) {
      debugPrint(error.toString());
      FluroRouter.router.navigateTo(context, SigninRoute);
      return false;
    }
  }

  void fetch() async {
    setState(() {
      projectsList.clear();
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('published', isEqualTo: true)
        .limit(limit)
        .get();

      if (snapshot.size == 0) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      lastDoc = snapshot.docs.last;

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        projectsList.add(Project.fromJSON(data));
      });

      setState(() {
        isLoading = false;
        hasNext = limit == snapshot.size;
      });

    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void delete(int index) async {
    setState(() => isLoading = true);

    final removedPost = projectsList.removeAt(index);

    try {
      await FirebaseFirestore.instance
        .collection('projects')
        .doc(removedPost.id)
        .delete();

      setState(() => isLoading = false);

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        projectsList.insert(index, removedPost);
      });
    }
  }

  void unpublish(int index) async {
    setState(() => isLoading = true);

    final removedPost = projectsList.removeAt(index);

    try {
      await FirebaseFirestore.instance
        .collection('projects')
        .doc(removedPost.id)
        .update({
          'published': false,
        });

      setState(() => isLoading = false);

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        projectsList.insert(index, removedPost);
      });
    }
  }

  void goToEditPage(Project project) async {
    await FluroRouter.router.navigateTo(
      context,
      EditProjectRoute.replaceFirst(':projectId', project.id),
    );

    fetch();
  }
}