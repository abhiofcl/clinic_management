// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmployeeAdapter extends TypeAdapter<Employee> {
  @override
  final int typeId = 5;

  @override
  Employee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Employee(
      name: fields[0] as String,
      age: fields[1] as int,
      address: fields[3] as String,
      gender: fields[2] as String,
      phoneNumber: fields[4] as String,
      idProofType: fields[5] as String,
      idProof: fields[6] as String,
      image: fields[7] as Uint8List?,
      dutySheet: (fields[8] as List?)?.cast<DutySheetEntry>(),
      status: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Employee obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.idProofType)
      ..writeByte(6)
      ..write(obj.idProof)
      ..writeByte(7)
      ..write(obj.image)
      ..writeByte(8)
      ..write(obj.dutySheet)
      ..writeByte(9)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DutySheetEntryAdapter extends TypeAdapter<DutySheetEntry> {
  @override
  final int typeId = 6;

  @override
  DutySheetEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DutySheetEntry(
      patientName: fields[2] as String?,
      date: fields[0] as DateTime?,
      timeSlot: fields[1] as String?,
      qty: fields[3] as String?,
      rate: fields[4] as String?,
      amount: fields[5] as String?,
      remarks: fields[6] as String?,
      dutyPerformed: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DutySheetEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.timeSlot)
      ..writeByte(2)
      ..write(obj.patientName)
      ..writeByte(3)
      ..write(obj.qty)
      ..writeByte(4)
      ..write(obj.rate)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.remarks)
      ..writeByte(7)
      ..write(obj.dutyPerformed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DutySheetEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
