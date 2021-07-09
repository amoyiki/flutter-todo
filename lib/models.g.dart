// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) {
  return TaskModel(
    id: json['id'],
    content: json['content'] as String,
    isComplete: json['isComplete']  as int,
    created: json['created'] as String,
    updated: json['updated'] as String,
  );
}

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'isComplete': instance.isComplete,
      'created': instance.created,
      'updated': instance.updated,
    };
