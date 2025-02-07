// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 0;

  @override
  Patient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Patient(
      name: fields[0] as String,
      age: fields[1] as int,
      occupation: fields[2] as String,
      address: fields[3] as String,
      nationality: fields[4] as String,
      maritalStatus: fields[5] as String,
      gender: fields[6] as String,
      ipNo: fields[7] as String,
      opNo: fields[8] as String,
      roomNo: fields[9] as String,
      dateOfAdmission: fields[10] as DateTime,
      dateOfDischarge: fields[11] as DateTime,
      diagnosis: fields[12] as String,
      presentComplaints: fields[13] as String,
      historyOfPresentComplaints: fields[39] as String,
      pastHistory: fields[40] as String,
      heartRate: fields[14] as String,
      bp: fields[23] as String,
      weight: fields[15] as String,
      height: fields[16] as String,
      diet: fields[17] as String,
      apetite: fields[18] as String,
      bowel: fields[19] as String,
      sleep: fields[20] as String,
      urine: fields[21] as String,
      habits: fields[34] as String,
      hereditary: fields[36] as String,
      sensitivity: fields[35] as String,
      menstrualHistory: fields[37] as String,
      image: fields[38] as Uint8List?,
      caseSheets: (fields[22] as List?)?.cast<CaseSheetEntry>(),
      status: fields[26] as String?,
      naadi: fields[42] as String,
      mutra: fields[43] as String,
      malam: fields[44] as String,
      jihwa: fields[45] as String,
      sabda: fields[46] as String,
      sparsa: fields[47] as String,
      drik: fields[48] as String,
      akriti: fields[49] as String,
    )
      ..billRegister = (fields[24] as List?)?.cast<BillEntry>()
      ..medicationsEntry = (fields[25] as List?)?.cast<MedicationsEntry>()
      ..condition = fields[27] as String?
      ..adice = fields[28] as String?
      ..otherMedication = fields[29] as String?
      ..treatment = fields[30] as String?
      ..totalBill = fields[31] as double
      ..days = fields[32] as int
      ..billNo = fields[33] as String
      ..consumables = (fields[41] as List?)?.cast<ConsumablesEntry>();
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer
      ..writeByte(50)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.occupation)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.nationality)
      ..writeByte(5)
      ..write(obj.maritalStatus)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.ipNo)
      ..writeByte(8)
      ..write(obj.opNo)
      ..writeByte(9)
      ..write(obj.roomNo)
      ..writeByte(10)
      ..write(obj.dateOfAdmission)
      ..writeByte(11)
      ..write(obj.dateOfDischarge)
      ..writeByte(12)
      ..write(obj.diagnosis)
      ..writeByte(13)
      ..write(obj.presentComplaints)
      ..writeByte(14)
      ..write(obj.heartRate)
      ..writeByte(15)
      ..write(obj.weight)
      ..writeByte(16)
      ..write(obj.height)
      ..writeByte(17)
      ..write(obj.diet)
      ..writeByte(18)
      ..write(obj.apetite)
      ..writeByte(19)
      ..write(obj.bowel)
      ..writeByte(20)
      ..write(obj.sleep)
      ..writeByte(21)
      ..write(obj.urine)
      ..writeByte(22)
      ..write(obj.caseSheets)
      ..writeByte(23)
      ..write(obj.bp)
      ..writeByte(24)
      ..write(obj.billRegister)
      ..writeByte(25)
      ..write(obj.medicationsEntry)
      ..writeByte(26)
      ..write(obj.status)
      ..writeByte(27)
      ..write(obj.condition)
      ..writeByte(28)
      ..write(obj.adice)
      ..writeByte(29)
      ..write(obj.otherMedication)
      ..writeByte(30)
      ..write(obj.treatment)
      ..writeByte(31)
      ..write(obj.totalBill)
      ..writeByte(32)
      ..write(obj.days)
      ..writeByte(33)
      ..write(obj.billNo)
      ..writeByte(34)
      ..write(obj.habits)
      ..writeByte(35)
      ..write(obj.sensitivity)
      ..writeByte(36)
      ..write(obj.hereditary)
      ..writeByte(37)
      ..write(obj.menstrualHistory)
      ..writeByte(38)
      ..write(obj.image)
      ..writeByte(39)
      ..write(obj.historyOfPresentComplaints)
      ..writeByte(40)
      ..write(obj.pastHistory)
      ..writeByte(41)
      ..write(obj.consumables)
      ..writeByte(42)
      ..write(obj.naadi)
      ..writeByte(43)
      ..write(obj.mutra)
      ..writeByte(44)
      ..write(obj.malam)
      ..writeByte(45)
      ..write(obj.jihwa)
      ..writeByte(46)
      ..write(obj.sabda)
      ..writeByte(47)
      ..write(obj.sparsa)
      ..writeByte(48)
      ..write(obj.drik)
      ..writeByte(49)
      ..write(obj.akriti);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CaseSheetEntryAdapter extends TypeAdapter<CaseSheetEntry> {
  @override
  final int typeId = 1;

  @override
  CaseSheetEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CaseSheetEntry(
      date: fields[0] as DateTime?,
      symptoms: fields[1] as String?,
      treatments: fields[2] as String?,
      bp: fields[3] as String?,
      time: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CaseSheetEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.symptoms)
      ..writeByte(2)
      ..write(obj.treatments)
      ..writeByte(3)
      ..write(obj.bp)
      ..writeByte(4)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseSheetEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillEntryAdapter extends TypeAdapter<BillEntry> {
  @override
  final int typeId = 2;

  @override
  BillEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillEntry(
      price: fields[0] as double?,
      particulars: fields[1] as String?,
      quantity: fields[2] as String?,
      rate: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BillEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.price)
      ..writeByte(1)
      ..write(obj.particulars)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.rate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicationsEntryAdapter extends TypeAdapter<MedicationsEntry> {
  @override
  final int typeId = 3;

  @override
  MedicationsEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationsEntry(
      name: fields[0] as String?,
      quantity: fields[1] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationsEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationsEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConsumablesEntryAdapter extends TypeAdapter<ConsumablesEntry> {
  @override
  final int typeId = 4;

  @override
  ConsumablesEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConsumablesEntry(
      price: fields[0] as double?,
      particulars: fields[1] as String?,
      quantity: fields[2] as String?,
      rate: fields[3] as String?,
      date: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ConsumablesEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.price)
      ..writeByte(1)
      ..write(obj.particulars)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.rate)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsumablesEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
