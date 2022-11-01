//
//  UIKitScrollView.swift
//  
//
//  Created by Wouter van de Kamp on 10/09/2022.
//

import Foundation
import UIKit
import SwiftUI

class UIScrollViewController: UIViewController {
    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))
    var height: CGFloat

    weak var scrollViewDelegate: UIScrollViewDelegate?

    init(height: CGFloat) {
        self.height = height
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(hostingController.view)

        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        view.addConstraints([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        updateScrollView()
    }
    
    func updateScrollView() {
        let scrollViews = view.findViews(subclassOf: UIScrollView.self)
        
        if !scrollViews.isEmpty {
            scrollViews[0].showsVerticalScrollIndicator = true
            scrollViews[0].delegate = scrollViewDelegate
        }
    }
}
