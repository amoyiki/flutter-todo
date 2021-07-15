
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'models.g.dart';


@JsonSerializable()
class TaskModel {
  int? id;
  String content;
  int isComplete;
  String? created;
  String? updated;

  TaskModel({
    required this.content,
    required this.isComplete,
    this.id,
    this.created,
    this.updated,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
  String get getInfo => 'TaskModel($id,$content)';
  
  
}