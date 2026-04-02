//
//  CryoStationPicker.swift
//  CryoKit
//
//  Created by Michael Fluharty on 3/31/26.
//

import SwiftUI
import MusicKit

public struct CryoStationPicker: View {
    @Bindable var player: MusicPlaybackManager
    let tint: Color
    let accent: Color
    let border: Color

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

    public init(
        player: MusicPlaybackManager,
        tint: Color = Color(red: 0.65, green: 0.82, blue: 0.95),
        accent: Color = Color(red: 0.5, green: 0.78, blue: 0.95),
        border: Color = Color(red: 0.35, green: 0.55, blue: 0.75)
    ) {
        self.player = player
        self.tint = tint
        self.accent = accent
        self.border = border
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
                        .font(.system(size: 12))
                        .foregroundStyle(border)
                        .frame(width: 20)

                    Text(category.rawValue)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundStyle(tint)

                    Spacer()

                    if !expandedCategories.contains(category) &&
                        player.currentStation.category == category {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12))
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
                        .font(.system(size: 11))
                        .foregroundStyle(border.opacity(0.7))
                        .frame(width: 20)

                    Text("ASMR")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(accent)

                    Spacer()

                    if !asmrExpanded &&
                        MusicStationOption.asmrStations.contains(player.currentStation) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11))
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
                        .font(.system(size: 12))
                        .foregroundStyle(border)
                        .frame(width: 20)

                    Text("Popular Hits")
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundStyle(tint)

                    Spacer()

                    if !expandedCategories.contains(.billboard) &&
                        player.currentStation.category == .billboard {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12))
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
                        .font(.system(size: 11))
                        .foregroundStyle(border.opacity(0.7))
                        .frame(width: 20)

                    Text(decade.rawValue)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(accent)

                    Spacer()

                    if !expandedDecades.contains(decade) &&
                        player.currentStation.decade == decade {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11))
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
                    .font(.system(size: 14))
                    .foregroundStyle(player.currentStation == station ? accent : border.opacity(0.5))

                Text(station.rawValue)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
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
                        .font(.system(size: 12))
                        .foregroundStyle(border)
                        .frame(width: 20)

                    Image(systemName: "music.note.house.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(accent)

                    Text("My Music")
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
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
                                    .font(.system(size: 12))
                                    .foregroundStyle(border.opacity(0.5))

                                VStack(alignment: .leading, spacing: 1) {
                                    Text(album.title)
                                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                                        .foregroundStyle(tint.opacity(0.7))
                                        .lineLimit(1)
                                    Text(album.artistName)
                                        .font(.system(size: 11, design: .monospaced))
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
                                    .font(.system(size: 12))
                                    .foregroundStyle(border.opacity(0.5))

                                Text(artist.name)
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
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
                        .font(.system(size: 11))
                        .foregroundStyle(border.opacity(0.7))
                        .frame(width: 20)

                    Text(title)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(accent)

                    Spacer()

                    Text("\(count)")
                        .font(.system(size: 12, design: .monospaced))
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
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: expandedPlaylistID == playlist.id ? "chevron.down" : "music.note.list")
                        .font(.system(size: 12))
                        .foregroundStyle(border.opacity(0.5))

                    Text(playlist.name)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .foregroundStyle(tint.opacity(0.7))
                        .lineLimit(1)

                    Spacer()

                    if expandedPlaylistID == playlist.id {
                        Text("\(revealedSongs.count) tracks")
                            .font(.system(size: 11, design: .monospaced))
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
                            .font(.system(size: 11))
                            .foregroundStyle(accent.opacity(0.7))

                        Text("Play All (\(revealedSongs.count) tracks)")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundStyle(accent.opacity(0.7))

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
                                .font(.system(size: 13, weight: .regular, design: .monospaced))
                                .foregroundStyle(tint.opacity(0.6))
                                .lineLimit(1)

                            Spacer()

                            Text(song.artistName)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(border.opacity(0.4))
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
