import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/backup_metadata.dart';
import '../repositories/backup_repository.dart';

/// Use case for creating a backup
class CreateBackup extends UseCase<BackupMetadata, NoParams> {
  final BackupRepository repository;

  CreateBackup(this.repository);

  @override
  Future<Either<Failure, BackupMetadata>> call(NoParams params) async {
    return await repository.createBackup();
  }
}
