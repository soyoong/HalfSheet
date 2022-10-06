//
//  HalfSheetModalView.swift
//  ThietThachClient
//
//  Created by Hau Nguyen on 14/12/2021.
//

import SwiftUI
import UIKit

@available(iOS 13.0, *)
@available(iOS 15.0, *)
public extension View {
    static func halfSheet<Content : View> (isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View {
        HalfSheetView(isPresented: isPresented, onDismiss: onDismiss, content: content)
    }
}

// 1 - Create a UISheetPresentationController that can be used in a SwiftUI interface
@available(iOS 13.0, *)
@available(iOS 15.0, *)
public struct HalfSheet<Content: View>: UIViewRepresentable {
    
    @Binding private var isPresented: Bool
    private let onDismiss: (() -> Void)?
    private let content: Content
    
    public init
    (
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    )
    {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.content = content()
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        
        // Create the UIViewController that will be presented by the UIButton
        let vc = UIViewController()
        
        // Create the UIHostingController that will embed the SwiftUI View
        let host = UIHostingController(rootView: content)
        
        // Add the UIHostingController to the UIViewController
        vc.addChild(host)
        vc.view.addSubview(host.view)
        // Set constraints
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.leftAnchor.constraint(equalTo: vc.view.leftAnchor).isActive = true
        host.view.topAnchor.constraint(equalTo: vc.view.topAnchor).isActive = true
        host.view.rightAnchor.constraint(equalTo: vc.view.rightAnchor).isActive = true
        host.view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor).isActive = true
        host.view.widthAnchor.constraint(equalTo: vc.view.widthAnchor).isActive = true
        host.view.heightAnchor.constraint(equalTo: vc.view.heightAnchor).isActive = true
        host.didMove(toParent: vc)
        
        // Set the presentationController as a UISheetPresentationController
        if let sheet = vc.presentationController as? UISheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            //sheet.largestUndimmedDetentIdentifier = .medium
            sheet.selectedDetentIdentifier = .medium
        }
        
        // Set the coordinator (delegate)
        // We need the delegate to use the presentationControllerDidDismiss function
        vc.presentationController?.delegate = context.coordinator
        
        
        if self.isPresented {
            // Present the viewController
            uiView.window?.rootViewController?.present(vc, animated: true)
        } else {
            // Dismiss the viewController
            uiView.window?.rootViewController?.dismiss(animated: true)
        }
        
    }
    
    /* Creates the custom instance that you use to communicate changes
     from your view controller to other parts of your SwiftUI interface.
     */
    public func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, onDismiss: onDismiss)
    }
    
    public class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        @Binding private var isPresented: Bool
        private let onDismiss: (() -> Void)?
        
        public init
        (
            isPresented: Binding<Bool>,
            onDismiss: (() -> Void)? = nil)
        {
            self._isPresented = isPresented
            self.onDismiss = onDismiss
        }
        
        public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            self.isPresented = false
            self.onDismiss?()
        }
    }
}

// 2 - Create the SwiftUI modifier conforming to the ViewModifier protocol
@available(iOS 13.0, *)
@available(iOS 15.0, *)
public struct HalfSheetView<Content : View>: View {
    
    @Binding private var isPresented: Bool
    
    private  let onDismiss: (() -> Void)?
    
    private let content: Content
    
    public init
    (
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content)
    {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.content = content()
    }
    
    public var body: some View {
        self.content
            .overlay(
                HalfSheet(isPresented: $isPresented, onDismiss: onDismiss) {
                    self.content
                }
            )
    }
    
//    public func body: some View {
//        content
//            .overlay(
//                HalfSheet(isPresented: $isPresented, onDismiss: onDismiss) {
//                    self.contentView
//                }.fixedSize()
//            )
//    }
}

