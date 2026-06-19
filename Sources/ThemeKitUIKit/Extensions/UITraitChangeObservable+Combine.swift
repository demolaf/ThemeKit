//
//  UITraitChangeObservable+Combine.swift
//  ThemeKit
//
//  Created by Ademola on 07/06/2026.
//
//  From: https://gist.github.com/pookjw/c32ca552d962ad17cc56fd74f6ad6abf

import Combine
import UIKit

extension UITraitChangeObservable where Self: AnyObject {
  /// Returns a publisher that emits whenever the given traits change on `traitEnvironment`.
  func traitChanges<TraitEnvironment: UITraitEnvironment>(
    traitEnvironment: TraitEnvironment.Type,
    traits: [UITrait]
  ) -> some Publisher<(TraitEnvironment, UITraitCollection), Never> {
    let subject = PassthroughSubject<(TraitEnvironment, UITraitCollection), Never>()
    let registration = registerForTraitChanges(traits) {
      [weak subject] (env: TraitEnvironment, previous: UITraitCollection) in
      subject?.send((env, previous))
    }
    return
      subject
      .handleEvents(receiveCancel: { [weak self, weak registration] in
        guard let registration else { return }
        self?.unregisterForTraitChanges(registration)
      })
  }
}
