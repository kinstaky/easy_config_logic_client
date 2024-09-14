//
//  Generated code. Do not modify.
//  source: ecl.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use requestDescriptor instead')
const Request$json = {
  '1': 'Request',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
  ],
};

/// Descriptor for `Request`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestDescriptor = $convert.base64Decode(
    'CgdSZXF1ZXN0EhIKBHR5cGUYASABKAVSBHR5cGU=');

@$core.Deprecated('Use responseDescriptor instead')
const Response$json = {
  '1': 'Response',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 5, '10': 'value'},
  ],
};

/// Descriptor for `Response`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseDescriptor = $convert.base64Decode(
    'CghSZXNwb25zZRIUCgV2YWx1ZRgBIAEoBVIFdmFsdWU=');

@$core.Deprecated('Use recentRequestDescriptor instead')
const RecentRequest$json = {
  '1': 'RecentRequest',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'flag', '3': 2, '4': 1, '5': 5, '10': 'flag'},
  ],
};

/// Descriptor for `RecentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recentRequestDescriptor = $convert.base64Decode(
    'Cg1SZWNlbnRSZXF1ZXN0EhIKBHR5cGUYASABKAVSBHR5cGUSEgoEZmxhZxgCIAEoBVIEZmxhZw'
    '==');

@$core.Deprecated('Use dateRequestDescriptor instead')
const DateRequest$json = {
  '1': 'DateRequest',
  '2': [
    {'1': 'year', '3': 1, '4': 1, '5': 5, '10': 'year'},
    {'1': 'month', '3': 2, '4': 1, '5': 5, '10': 'month'},
    {'1': 'day', '3': 3, '4': 1, '5': 5, '10': 'day'},
    {'1': 'flag', '3': 4, '4': 1, '5': 5, '10': 'flag'},
  ],
};

/// Descriptor for `DateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dateRequestDescriptor = $convert.base64Decode(
    'CgtEYXRlUmVxdWVzdBISCgR5ZWFyGAEgASgFUgR5ZWFyEhQKBW1vbnRoGAIgASgFUgVtb250aB'
    'IQCgNkYXkYAyABKAVSA2RheRISCgRmbGFnGAQgASgFUgRmbGFn');

@$core.Deprecated('Use expressionDescriptor instead')
const Expression$json = {
  '1': 'Expression',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `Expression`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List expressionDescriptor = $convert.base64Decode(
    'CgpFeHByZXNzaW9uEhQKBXZhbHVlGAEgASgJUgV2YWx1ZQ==');

