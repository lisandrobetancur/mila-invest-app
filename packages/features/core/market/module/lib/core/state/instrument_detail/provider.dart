part of 'instrument_detail.dart';

/// Provider del controller del detalle, por id de instrumento.
final AutoDisposeNotifierProviderFamily<
  InstrumentDetailViewModel,
  InstrumentDetailState,
  String
>
instrumentDetailViewModelProvider = NotifierProvider.autoDispose
    .family<InstrumentDetailViewModel, InstrumentDetailState, String>(
      InstrumentDetailViewModel.new,
    );
