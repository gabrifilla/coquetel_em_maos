import 'package:coquetel_em_maos/repositories/repository.dart';
import 'package:coquetel_em_maos/models/dropdownItem.dart';

class DropdownService{
  Repository _repository;

  DropdownService(){
    _repository = Repository();
  }

  readDD() async{
    return await _repository.readData('dropdownInfos');
  }
}