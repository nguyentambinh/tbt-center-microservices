/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart' show DateTimeRange;

import '../entities/project.dart';
import '../entities/proposal.dart';

abstract interface class ProjectRepository {
  Future<List<ProjectSummary>> projects({String? search, int? tier, DateTimeRange? range});

  Future<ProjectDetail> project(String id);

  Future<List<MyProject>> myProjects();

  /// Nghiệm thu: server ghi doanh thu ở tài chính rồi đổi trạng thái dự án (R100).
  Future<ProjectDetail> accept(String id);

  Future<List<ProjectProposal>> proposals({String? status});

  Future<ProjectProposal> proposal(int id);

  /// Tải hợp đồng (kind `contract`) hoặc ảnh (`image`) lên kho, trả khóa object
  Future<String> uploadFile({required String kind, required String fileName, required List<int> bytes});

  /// AI đọc hợp đồng đã tải lên; `source` là `manual` khi phải nhập tay
  Future<({ProposalData fields, String source})> extract({required String objectKey, required String fileName});

  Future<MemberSuggestion> suggestMembers(ProposalData data, {required String language});

  Future<ProjectProposal> propose(ProposalData data, {String? contractKey, String? contractName, String? imageKey});

  /// approve, counter (kèm [data] đã sửa), reject, withdraw
  Future<ProjectProposal> respond(int id, {required String action, ProposalData? data, String? note});
}
