extension TransactionStateExt on TransactionState {
  bool get isPurchased => this == TransactionState.purchased;
  bool get isPurchasing => this == TransactionState.purchasing;

  // TODO: handle deffered
  bool get isFinished => !isPurchasing;

  static TransactionState fromIOSState(final int id) {
    switch (id) {
      case 0:
        return TransactionState.purchasing;
      case 1:
        return TransactionState.purchased;
      case 2:
        return TransactionState.failed;
      case 3:
        // TODO:?
        // We use purchased state for restored
        return TransactionState.purchased;
      case 4:
        return TransactionState.deffered;

      default:
        throw 'unknown state';
    }
  }
}

enum TransactionState { purchasing, deffered, purchased, failed, userCanceled }
