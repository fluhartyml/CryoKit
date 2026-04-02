//
//  CryoStationPicker.swift
//  CryoKit
//
//  Created by Michael Fluharty on 3/31/26.
//

import SwiftUI
import MusicKit

// fontSize: Base font size for body text. Defaults to 14 (iPhone/iPad).
// tvOS apps should pass a larger value (e.g. 28) to scale all text proportionally.
// All font sizes in this view scale relative to this base value.
public struct CryoStationPicker: View {
    @Bindable var player: MusicPlaybackManager
    let tint: Color
    let accent: Color
    let border: Color
    let fontSize: CGFloat

    @State private var expandedCategories: Set<StationCategory> = []
    @State private var expandedDecades: Set<BillboardDecade> = []
    @State private var asmrExpanded = false
    @State private var myMusicExpanded = false
    @State private var playlistsExpanded = false
    @State private var albumsExpanded = false
    @State private var artistsExpanded = false
    @State private var libraryLoaded = false
    @State private var expandedPlaylistID: MusicItemID?
    @State private var revealedSongs: [Song] = []
    @State private var playlistTrackCounts: [MusicItemID: Int] = [:]

    // Computed scaled font sizes relative to fontSize base (default 14)
    private var fontSmall: CGFloat { fontSize * 0.79 }      // ~11 at base 14
    private var fontIcon: CGFloat { fontSize * 0.86 }       // ~12 at base 14
    private var fontBody: CGFloat { fontSize }               // 14 at base 14
    private var fontMedium: CGFloat { fontSize * 1.14 }      // ~16 at base 14
    private var fontLarge: CGFloat { fontSize * 1.29 }       // ~18 at base 14

    public init(
        player: MusicPlaybackManager,
        tint: Color = Color(red: 0.65, green: 0.82, blue: 0.95),
        accent: Color = Color(red: 0.5, green: 0.78, blue: 0.95),
        border: Color = Color(red: 0.35, green: 0.55, blue: 0.75),
        fontSize: CGFloat = 18
    ) {
        self.player = player
        self.tint = tint
        self.accent = accent
        self.border = border
        self.fontSize = fontSize
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(StationCategory.allCases, id: \.self) { category in
                if category == .billboard {
                    billboardCategoryPicker
                } else {
                    stationCategoryPicker(category: category)
                }
            }

            myMusicPicker
        }
    }

    // MARK: - Station Category

    private func stationCategoryPicker(category: StationCategory) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if expandedCategories.contains(category) {
                        expandedCategories.remove(category)
                    } else {
                        expandedCategories.insert(category)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: expandedCategories.contains(category) ? "chevron.down" : "chevron.right")
                        .font(.system(size: fontIcon))
                        .foregroundStyle(border)
                        .frame(width: 20)

                    Text(category.rawValue)
                        .font(.system(size: fontMedium, weight: .semibold, design: .monospaced))
                        .foregroundStyle(tint)

                    Spacer()

                    if !expandedCategories.contains(category) &&
                        player.currentStation.category == category {
                        Image(systemName: "checkmark")
                            .font(.system(size: fontIcon))
                            .foregroundStyle(accent)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
            }

            if expandedCategories.contains(category) {
                ForEach(MusicStationOption.stations(for: category), id: \.self) { station in
                    stationRow(station: station)
                }

                if category == .nature {
                    asmrSubSection
                }
            }
        }
    }

    // MARK: - ASMR

    private var asmrSubSection: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    asmrExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: asmrExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: fontSmall))
                        .foregroundStyle(border.opacity(0.7))
                        .frame(width: 20)

                    Text("ASMR")
                        .font(.system(size: fontBody, weight: .medium, design: .monospaced))
                        .foregroundStyle(accent)

                    Spacer()

                    if !asmrExpanded &&
                        MusicStationOption.asmrStations.contains(player.currentStation) {
                        Image(systemName: "checkmark")
                            .font(.system(size: fontSmall))
                            .foregroundStyle(accent)
                    }
                }
                .padding(.vertical, 8)
                .padding(.leading, 28)
                .padding(.trailing, 8)
            }

            if asmrExpanded {
                ForEach(MusicStationOption.asmrStations, id: \.self) { station in
                    stationRow(station: station, indent: true)
                }
            }
        }
    }

    // MARK: - Billboard / Popular Hits

    private var billboardCategoryPicker: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if expandedCategories.contains(.billboard) {
                        expandedCategories.remove(.billboard)
                    } else {
                        expandedCategories.insert(.billboard)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: expandedCategories.contains(.billboard) ? "chevron.down" : "chevron.right")
                        .font(.system(size: fontIcon))
                        .foregroundStyle(border)
                        .frame(width: 20)

                    Text("Popular Hits")
                        .font(.system(size: fontMedium, weight: .semibold, design: .monospaced))
                        .foregroundStyle(tint)

                    Spacer()

                    if !expandedCategories.contains(.billboard) &&
                        player.currentStation.category == .billboard {
                        Image(systemName: "checkmark")
                            .font(.system(size: fontIcon))
                            .foregroundStyle(accent)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
            }

            if expandedCategories.contains(.billboard) {
                stationRow(station: .top100USA)

                ForEach(BillboardDecade.allCases, id: \.self) { decade in
                    decadePicker(decade: decade)
                }
            }
        }
    }

    private func decadePicker(decade: BillboardDecade) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if expandedDecades.contains(decade) {
                        expandedDecades.remove(decade)
                    } else {
                        expandedDecades.insert(decade)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: expandedDecades.contains(decade) ? "chevron.down" : "chevron.right")
                        .font(.system(size: fontSmall))
                        .foregroundStyle(border.opacity(0.7))
                        .frame(width: 20)

                    Text(decade.rawValue)
                        .font(.system(size: fontBody, weight: .medium, design: .monospaced))
                        .foregroundStyle(accent)

                    Spacer()

                    if !expandedDecades.contains(decade) &&
                        player.currentStation.decade == decade {
                        Image(systemName: "checkmark")
                            .font(.system(size: fontSmall))
                            .foregroundStyle(accent)
                    }
                }
                .padding(.vertical, 8)
                .padding(.leading, 28)
                .padding(.trailing, 8)
            }

            if expandedDecades.contains(decade) {
                ForEach(MusicStationOption.stations(for: decade), id: \.self) { station in
                    stationRow(station: station, indent: true)
                }
            }
        }
    }

    // MARK: - Station Row

    private func stationRow(station: MusicStationOption, indent: Bool = false) -> some View {
        Button {
            Task {
                await player.play(station: station)
            }
        } label: {
            HStack {
                Image(systemName: player.currentStation == station ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: fontBody))
                    .foregroundStyle(player.currentStation == station ? accent : border.opacity(0.5))

                Text(station.rawValue)
                    .font(.system(size: fontBody, weight: .regular, design: .monospaced))
                    .foregroundStyle(player.currentStation == station ? tint : tint.opacity(0.7))

                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.leading, indent ? 48 : 28)
            .padding(.trailing, 8)
        }
    }

    // MARK: - My Music

    private var myMusicPicker: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    myMusicExpanded.toggle()
                    if myMusicExpanded && !libraryLoaded {
                        libraryLoaded = true
                        Task { await player.loadLibrary() }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: myMusicExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: fontIcon))
                        .foregroundStyle(border)
                        .frame(width: 20)

                    Image(systemName: "music.note.house.fill")
                        .font(.system(size: fontBody))
                        .foregroundStyle(accent)

                    Text("My Music")
                        .font(.system(size: fontMedium, weight: .semibold, design: .monospaced))
                        .foregroundStyle(tint)

                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
            }

            if myMusicExpanded {
                // Playlists
                librarySubSection(
                    title: "Playlists",
                    count: player.libraryPlaylists.count,
                    isExpanded: $playlistsExpanded
                ) {
                    ForEach(player.libraryPlaylists, id: \.id) { playlist in
                        playlistRevealRow(playlist: playlist)
                    }
                    .onAppear { loadAllPlaylistCounts() }
                }

                // Albums
                librarySubSection(
                    title: "Albums",
                    count: player.libraryAlbums.count,
                    isExpanded: $albumsExpanded
                ) {
                    ForEach(player.libraryAlbums, id: \.id) { album in
                        Button {
                            Task { await player.playAlbum(album) }
                        } label: {
                            HStack {
                                Image(systemName: "square.stack")
                                    .font(.system(size: fontIcon))
                                    .foregroundStyle(border.opacity(0.5))

                                VStack(alignment: .leading, spacing: 1) {
                                    Text(album.title)
                                        .font(.system(size: fontBody, weight: .regular, design: .monospaced))
                                        .foregroundStyle(tint.opacity(0.7))
                                        .lineLimit(1)
                                    Text(album.artistName)
                                        .font(.system(size: fontSmall, design: .monospaced))
                                        .foregroundStyle(border.opacity(0.5))
                                        .lineLimit(1)
                                }

                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .padding(.leading, 48)
                            .padding(.trailing, 8)
                        }
                    }
                }

                // Artists
                librarySubSection(
                    title: "Artists",
                    count: player.libraryArtists.count,
                    isExpanded: $artistsExpanded
                ) {
                    ForEach(player.libraryArtists, id: \.id) { artist in
                        Button {
                            Task { await player.loadSongs(for: artist) }
                        } label: {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.system(size: fontIcon))
                                    .foregroundStyle(border.opacity(0.5))

                                Text(artist.name)
                                    .font(.system(size: fontBody, weight: .regular, design: .monospaced))
                                    .foregroundStyle(tint.opacity(0.7))
                                    .lineLimit(1)

                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .padding(.leading, 48)
                            .padding(.trailing, 8)
                        }
                    }
                }
            }
        }
    }

    private func librarySubSection<Content: View>(
        title: String,
        count: Int,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.wrappedValue.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: isExpanded.wrappedValue ? "chevron.down" : "chevron.right")
                        .font(.system(size: fontSmall))
                        .foregroundStyle(border.opacity(0.7))
                        .frame(width: 20)

                    Text(title)
                        .font(.system(size: fontBody, weight: .medium, design: .monospaced))
                        .foregroundStyle(accent)

                    Spacer()

                    Text("\(count)")
                        .font(.system(size: fontIcon, design: .monospaced))
                        .foregroundStyle(border.opacity(0.5))
                }
                .padding(.vertical, 8)
                .padding(.leading, 28)
                .padding(.trailing, 8)
            }

            if isExpanded.wrappedValue {
                content()
            }
        }
    }

    // MARK: - Playlist Track Count Loader

    private func loadAllPlaylistCounts() {
        for playlist in player.libraryPlaylists {
            guard playlistTrackCounts[playlist.id] == nil else { continue }
            Task {
                let detailed = try? await playlist.with([.tracks])
                let count = detailed?.tracks?.count ?? 0
                await MainActor.run {
                    playlistTrackCounts[playlist.id] = count
                }
            }
        }
    }

    // MARK: - Playlist Reveal Row

    private func playlistRevealRow(playlist: Playlist) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if expandedPlaylistID == playlist.id {
                        expandedPlaylistID = nil
                        revealedSongs = []
                    } else {
                        expandedPlaylistID = playlist.id
                        Task {
                            let detailed = try? await playlist.with([.tracks])
                            let tracks = detailed?.tracks ?? []
                            revealedSongs = tracks.compactMap { track in
                                if case let .song(song) = track { return song }
                                return nil
                            }
                            playlistTrackCounts[playlist.id] = revealedSongs.count
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: expandedPlaylistID == playlist.id ? "chevron.down" : "music.note.list")
                        .font(.system(size: fontBody))
                        .foregroundStyle(border.opacity(0.5))

                    Text(playlist.name)
                        .font(.system(size: fontLarge, weight: .regular, design: .monospaced))
                        .foregroundStyle(tint.opacity(0.7))
                        .lineLimit(1)

                    Spacer()

                    if expandedPlaylistID == playlist.id {
                        Text("\(revealedSongs.count) tracks")
                            .font(.system(size: fontBody, design: .monospaced))
                            .foregroundStyle(border.opacity(0.6))
                    } else if let count = playlistTrackCounts[playlist.id] {
                        Text("\(count)")
                            .font(.system(size: fontBody, design: .monospaced))
                            .foregroundStyle(border.opacity(0.5))
                    }
                }
                .padding(.vertical, 6)
                .padding(.leading, 48)
                .padding(.trailing, 8)
            }

            // Revealed track list
            if expandedPlaylistID == playlist.id {
                // Play All
                Button {
                    Task { await player.playPlaylist(playlist) }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.system(size: fontBody))
                            .foregroundStyle(accent.opacity(0.8))

                        Text("Play All (\(revealedSongs.count) tracks)")
                            .font(.system(size: fontLarge, weight: .medium, design: .monospaced))
                            .foregroundStyle(accent.opacity(0.8))

                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .padding(.leading, 62)
                    .padding(.trailing, 8)
                }

                // Individual songs
                ForEach(revealedSongs, id: \.id) { song in
                    Button {
                        Task { await player.playSong(song) }
                    } label: {
                        HStack {
                            Text(song.title)
                                .font(.system(size: fontLarge, weight: .regular, design: .monospaced))
                                .foregroundStyle(tint.opacity(0.7))
                                .lineLimit(1)

                            Spacer()

                            Text(song.artistName)
                                .font(.system(size: fontMedium, design: .monospaced))
                                .foregroundStyle(border.opacity(0.6))
                                .lineLimit(1)
                        }
                        .padding(.vertical, 4)
                        .padding(.leading, 62)
                        .padding(.trailing, 8)
                    }
                }
            }
        }
    }
}
