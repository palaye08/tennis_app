package com.tennis.controller;

import com.tennis.dto.ApiResponse;
import com.tennis.dto.MatchDto;
import com.tennis.dto.MatchRequest;
import com.tennis.service.MatchService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/matches")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:4200")
public class MatchController {

    private final MatchService matchService;

    @PostMapping
    public ApiResponse<MatchDto> createMatch(@Valid @RequestBody MatchRequest request) {
        return ApiResponse.success(matchService.createMatch(request));
    }
// je suis dans match-delete
    @GetMapping
    public ApiResponse<Page<MatchDto>> getAllMatches(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.success(matchService.getAllMatches(PageRequest.of(page, size)));
    }

    @GetMapping("/{id}")
    public ApiResponse<MatchDto> getMatchById(@PathVariable Long id) {
        return ApiResponse.success(matchService.getMatchById(id));
    }

    @PutMapping("/{id}")
    public ApiResponse<MatchDto> updateMatch(@PathVariable Long id, @Valid @RequestBody MatchRequest request) {
        return ApiResponse.success(matchService.updateMatch(id, request));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteMatch(@PathVariable Long id) {
        matchService.deleteMatch(id);
        return ApiResponse.success(null);
    }
}
