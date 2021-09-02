import 'package:flutter/material.dart';
import 'package:coquetel_em_maos/helpers/drawer_navigation.dart';
import 'package:coquetel_em_maos/models/category.dart';
import 'package:coquetel_em_maos/services/categories.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {

  var _nomeController = TextEditingController();
  var _descController = TextEditingController();
  var _editnomeController = TextEditingController();
  var _editdescController = TextEditingController();
  var _category = Category();
  var _categoryService = CategoryService();

  var category;

  // ignore: deprecated_member_use
  List<Category> _categoryList = List<Category>();

  @override
  void initState(){
    super.initState();
    getAllCategories();
  }

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  getAllCategories() async{
    // ignore: deprecated_member_use
    _categoryList = List<Category>();
    var categories = await _categoryService.readCategory();
    categories.forEach((category){
      setState(() {
        var categoryModel = Category();
        categoryModel.nome = category['nome'];
        categoryModel.descricao = category['descricao'];
        categoryModel.id = category['id'];
        _categoryList.add(categoryModel);
      });
    });
  }

  _editCategory(BuildContext context, categoryId) async {
    category = await _categoryService.readCategoryById(categoryId);
    setState(() {
      _editdescController.text = category[0]['nome']??'Sem Nome';
      _editnomeController.text = category[0]['descricao']??'Sem Descrição';
    });
    _editFormDialog(context);
  }

  _showFormDialog (BuildContext context){
    String dropdownValue = 'One';
    showDialog(context: context,barrierDismissible: true, builder: (param){
      return AlertDialog(
        actions: <Widget>[
          // ignore: deprecated_member_use
          FlatButton(
              onPressed: ()=>Navigator.pop(context),
              child: Text('Cancelar')
          ),
          // ignore: deprecated_member_use
          FlatButton(
            onPressed: () async {
              _category.nome = _nomeController.text;
              _category.descricao = _descController.text;
              var result = await _categoryService.saveCategory(_category);
              if(result > 0) {
                Navigator.pop(context);
                getAllCategories();
                _showSuccessSnackBar(Text('Salvo'));
              }
            },
            child: Text('Salvar'),
          )
        ],
        title: Text("Insira as informações"),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                    hintText: 'Escreva o nome',
                    labelText: 'Nome'
                ),
              ),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                    hintText: 'Escreva a Descrição',
                    labelText: 'Descrição'
                ),
              ),
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                },
                items: <String>['One', 'Two', 'Free', 'Four']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });
  }

  _editFormDialog (BuildContext context){
    showDialog(context: context,barrierDismissible: true, builder: (param){
      return AlertDialog(
        actions: <Widget>[
          // ignore: deprecated_member_use
          FlatButton(
              onPressed: ()=>Navigator.pop(context),
              child: Text('Cancelar')
          ),
          // ignore: deprecated_member_use
          FlatButton(
            onPressed: () async {
              _category.id = category[0]['id'];
              _category.nome = _editnomeController.text;
              _category.descricao = _editdescController.text;
              var result = await _categoryService.updateCategory(_category);
              if(result > 0){
                print(result);
                Navigator.pop(context);
                getAllCategories();
                _showSuccessSnackBar(Text('Atualizado'));
              }
            },
            child: Text('Alterar'),
          )
        ],
        title: Text("Editar as informações"),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _editnomeController,
                decoration: InputDecoration(
                    hintText: 'Escreva o nome',
                    labelText: 'Nome'
                ),
              ),
              TextField(
                controller: _editdescController,
                decoration: InputDecoration(
                    hintText: 'Escreva a Descrição',
                    labelText: 'Descrição'
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  _deleteFormDialog (BuildContext context, categoryId){
    showDialog(context: context,barrierDismissible: true, builder: (param){
      return AlertDialog(
        actions: <Widget>[
          // ignore: deprecated_member_use
          FlatButton(
              color: Colors.green,
              onPressed: ()=>Navigator.pop(context),
              child: Text('Cancelar')
          ),
          // ignore: deprecated_member_use
          FlatButton(
            color: Colors.red,
            onPressed: () async {
              var result = await _categoryService.deleteCategory(categoryId);
              if(result > 0){
                print(result);
                Navigator.pop(context);
                getAllCategories();
                _showSuccessSnackBar(Text('Deletado'));
              }
            },
            child: Text('Delete'),
          )
        ],
        title: Text("Certeza que quer deletar este item?"),
      );
    });
  }

  _showSuccessSnackBar(message){
    var _snackBar = SnackBar(content: message);
    // ignore: deprecated_member_use
    _globalKey.currentState.showSnackBar(_snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text("Categorias"),
      ),
      body: ListView.builder(
          itemCount: _categoryList.length,
          itemBuilder: (context, index){
            return Padding(
              padding: EdgeInsets.only(top:8.0, left: 16.0, right: 16.0),
              child: Card(
                elevation: 8.0,
                child: ListTile(
                  leading: IconButton(
                      color: Colors.lightBlueAccent,
                      icon: Icon(Icons.edit),
                      onPressed: (){
                        _editCategory(context, _categoryList[index].id);
                      }
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(_categoryList[index].nome),
                      IconButton(
                        color: Colors.red,
                        icon: Icon(Icons.delete),
                        onPressed: (){
                          _deleteFormDialog(context, _categoryList[index].id);
                        },
                      )
                    ],
                  ),
                  subtitle: Text(_categoryList[index].descricao),
                ),
              ),
            );
          }),
      drawer: DrawerNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showFormDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
