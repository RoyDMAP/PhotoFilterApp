import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var filteredImage: UIImage?
    @State private var showCameraPicker = false
    @State private var showLibraryPicker = false
    @State private var selectedFilter: FilterType = .none
    @State private var filterIntensity: Double = 1.0
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Image Display Area
                if let image = filteredImage ?? selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("No Image Selected")
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: 400)
                }
                
                // Filter Intensity Slider
                if selectedImage != nil && selectedFilter != .none {
                    VStack(alignment: .leading) {
                        Text("Filter Intensity: \(Int(filterIntensity * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $filterIntensity, in: 0...1)
                            .onChange(of: filterIntensity) { oldValue, newValue in
                                applyFilter()
                            }
                    }
                    .padding(.horizontal)
                }
                
                // Filter Options
                if selectedImage != nil {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(FilterType.allCases, id: \.self) { filter in
                                FilterButton(
                                    title: filter.displayName,
                                    isSelected: selectedFilter == filter
                                ) {
                                    selectedFilter = filter
                                    applyFilter()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 20) {
                    // Camera Button
                    Button(action: {
                        print("Camera button tapped")
                        showCameraPicker = true
                    }) {
                        Label("Camera", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // Photo Library Button
                    Button(action: {
                        print("Library button tapped")
                        showLibraryPicker = true
                    }) {
                        Label("Library", systemImage: "photo.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                // Save Button
                if filteredImage != nil {
                    Button(action: saveImage) {
                        Label("Save to Photos", systemImage: "square.and.arrow.down.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Photo Filter")
            .sheet(isPresented: $showCameraPicker) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
                    .onDisappear {
                        if selectedImage != nil {
                            selectedFilter = .none
                            filteredImage = nil
                            filterIntensity = 1.0
                        }
                    }
            }
            .sheet(isPresented: $showLibraryPicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
                    .onDisappear {
                        if selectedImage != nil {
                            selectedFilter = .none
                            filteredImage = nil
                            filterIntensity = 1.0
                        }
                    }
            }
            .alert("Message", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // Apply selected filter to image
    private func applyFilter() {
        guard let image = selectedImage else { return }
        
        if selectedFilter == .none {
            filteredImage = nil
            return
        }
        
        filteredImage = FilterService.applyFilter(
            to: image,
            filterType: selectedFilter,
            intensity: filterIntensity
        )
    }
    
    // Save image to photo library
    private func saveImage() {
        guard let imageToSave = filteredImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        alertMessage = "Image saved successfully!"
        showAlert = true
    }
}

// Filter Button Component
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    ContentView()
}
