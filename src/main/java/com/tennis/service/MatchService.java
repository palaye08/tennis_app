package com.tennis.service;

import com.tennis.dto.MatchDto;
import com.tennis.dto.MatchRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface MatchService {
    MatchDto createMatch(MatchRequest request);
    Page<MatchDto> getAllMatches(Pageable pageable);
    MatchDto getMatchById(Long id);
    MatchDto updateMatch(Long id, MatchRequest request);
    void deleteMatch(Long id);
}
