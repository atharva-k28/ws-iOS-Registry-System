//
//  GiftConciergeChatView.swift
//  iOS_Registry_System
//
//  Frosted glass Gift Concierge conversational AI shopping assistant.
//

import SwiftUI

struct GiftConciergeChatView: View {
    let registryItems: [RegistryItem]
    let products: [UUID: Product]
    
    @Environment(\.dismiss) private var dismiss
    
    struct ChatMessage: Identifiable, Equatable {
        let id = UUID()
        let text: String
        let isUser: Bool
        let product: Product?
    }
    
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @State private var selectedProduct: Product? = nil
    
    let suggestionPrompts = [
        "Kitchen under $100",
        "Coffee essentials",
        "Top priority items",
        "Budget friendly"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat bubbles scroll list
                chatList
                
                // Typing indicator
                if isLoading {
                    typingIndicator
                }
                
                // Suggested prompt chips
                if messages.count <= 1 && !isLoading {
                    suggestionsStrip
                }
                
                // Input panel
                inputPanel
            }
            .appBackground()
            .navigationTitle("Gift Concierge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.accentRed)
                }
            }
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(product: product)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
            }
            .onAppear {
                if messages.isEmpty {
                    messages.append(ChatMessage(
                        text: "Hi! 🎁 I'm your AI Gift Concierge. Ask me anything about this registry! I can suggest gifts matching a budget, specific category, or special preferences.",
                        isUser: false,
                        product: nil
                    ))
                }
            }
        }
    }
    
    // MARK: - Chat List
    
    private var chatList: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.md) {
                    ForEach(messages) { msg in
                        messageRow(msg)
                            .id(msg.id)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.lg)
            }
            .onChange(of: messages) { oldValue, newValue in
                if let lastId = newValue.last?.id {
                    withAnimation {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Message Row
    
    private func messageRow(_ msg: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            if msg.isUser {
                Spacer()
            } else {
                Image(systemName: "sparkles")
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle().fill(AppColors.accentRed)
                    )
            }
            
            VStack(alignment: msg.isUser ? .trailing : .leading, spacing: AppSpacing.sm) {
                Text(msg.text)
                    .font(AppTypography.body)
                    .foregroundStyle(msg.isUser ? .white : AppColors.primaryText)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(msg.isUser ? AppColors.accentRed : AppColors.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(msg.isUser ? Color.clear : Color.black.opacity(0.04), lineWidth: 0.5)
                            )
                    )
                    .softShadow()
                
                // recommended product card
                if let prod = msg.product {
                    recommendedProductCard(prod)
                }
            }
            .frame(maxWidth: 290, alignment: msg.isUser ? .trailing : .leading)
            
            if !msg.isUser {
                Spacer()
            }
        }
    }
    
    // MARK: - Recommended Product Card
    
    private func recommendedProductCard(_ prod: Product) -> some View {
        Button {
            selectedProduct = prod
        } label: {
            HStack(spacing: AppSpacing.md) {
                AsyncImage(url: URL(string: prod.imageUrl ?? "")) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.backgroundGray)
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text((prod.brand ?? "").uppercased())
                        .font(AppTypography.caption2)
                        .foregroundStyle(AppColors.secondaryGray)
                        .tracking(1)
                    
                    Text(prod.name)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)
                    
                    Text(CurrencyFormatter.formatCompact(prod.price))
                        .font(AppTypography.subheadlineMedium)
                        .foregroundStyle(AppColors.accentRed)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppColors.secondaryGray)
            }
            .padding(AppSpacing.sm)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(AppColors.accentRed.opacity(0.15), lineWidth: 1)
            )
            .softShadow()
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Suggestions Strip
    
    private var suggestionsStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(suggestionPrompts, id: \.self) { prompt in
                    Button {
                        inputText = prompt
                        sendMessage()
                    } label: {
                        Text(prompt)
                            .font(AppTypography.caption1Medium)
                            .foregroundStyle(AppColors.primaryText)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(AppColors.white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, AppSpacing.sm)
        }
    }
    
    // MARK: - Typing Indicator
    
    private var typingIndicator: some View {
        HStack(spacing: 4) {
            Circle().fill(AppColors.secondaryGray.opacity(0.6)).frame(width: 6, height: 6)
            Circle().fill(AppColors.secondaryGray.opacity(0.6)).frame(width: 6, height: 6)
            Circle().fill(AppColors.secondaryGray.opacity(0.6)).frame(width: 6, height: 6)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 8)
        .background(Capsule().fill(AppColors.white))
        .softShadow()
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 50)
        .padding(.bottom, AppSpacing.sm)
    }
    
    // MARK: - Input Panel
    
    private var inputPanel: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: AppSpacing.sm) {
                HStack {
                    TextField("Ask concierge...", text: $inputText)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.primaryText)
                        .onSubmit {
                            sendMessage()
                        }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, 10)
                .background(Capsule().fill(AppColors.backgroundGray.opacity(0.5)))
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(inputText.isEmpty ? AppColors.secondaryGray : AppColors.accentRed)
                        )
                }
                .disabled(inputText.isEmpty)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.md)
            .background(.ultraThinMaterial)
        }
    }
    
    // MARK: - Send Action
    
    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        inputText = ""
        messages.append(ChatMessage(text: trimmed, isUser: true, product: nil))
        
        isLoading = true
        
        Task {
            let res = await AIService.shared.askConcierge(
                guestPrompt: trimmed,
                registryItems: registryItems,
                products: products
            )
            
            var recommendedProduct: Product? = nil
            if let pid = res.recommendedProductId {
                recommendedProduct = products[pid]
            }
            
            withAnimation {
                isLoading = false
                messages.append(ChatMessage(
                    text: res.chatResponse,
                    isUser: false,
                    product: recommendedProduct
                ))
            }
        }
    }
}
