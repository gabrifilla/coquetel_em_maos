import 'package:coquetel_em_maos/repositories/repository.dart';
import 'package:coquetel_em_maos/models/category.dart';

class CategoryService{
  Repository _repository;

  CategoryService(){
    _repository = Repository();
  }

  saveCategory(Category category) async{
    return await _repository.insertData("categoria", category.categoryMap());
  }

  readCategory() async{
    return await _repository.readData('categoria');
  }

  readCategoryById(categoryId) async{
    return await _repository.readDataById('categoria', categoryId);
  }

  updateCategory(Category category) async{
    return await _repository.updateData('categoria', category.categoryMap());
  }

  deleteCategory(categoryId) async{
    return await _repository.deleteData('categoria', categoryId);
  }
}