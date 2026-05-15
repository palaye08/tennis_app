package com.tennis.service.impl;

import com.tennis.dto.MatchDto;
import com.tennis.dto.MatchRequest;
import com.tennis.mapper.MatchMapper;
import com.tennis.model.entity.Match;
import com.tennis.repository.MatchRepository;
import com.tennis.service.MatchService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class MatchServiceImpl implements MatchService {

    private final MatchRepository matchRepository;
    private final MatchMapper matchMapper;

    @Override
    public MatchDto createMatch(MatchRequest request) {
        Match match = matchMapper.toEntity(request);
        return matchMapper.toDto(matchRepository.save(match));
    }

    @Override
    @Transactional(readOnly = true)
    public Page<MatchDto> getAllMatches(Pageable pageable) {
        return matchRepository.findAll(pageable).map(matchMapper::toDto);
    }

    @Override
    @Transactional(readOnly = true)
    public MatchDto getMatchById(Long id) {
        return matchRepository.findById(id)
                .map(matchMapper::toDto)
                .orElseThrow(() -> new EntityNotFoundException("Match non trouvé avec l'id : " + id));
    }

    @Override
    public MatchDto updateMatch(Long id, MatchRequest request) {
        Match match = matchRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Match non trouvé avec l'id : " + id));
        matchMapper.updateEntityFromRequest(request, match);
        return matchMapper.toDto(matchRepository.save(match));
    }

    @Override
    public void deleteMatch(Long id) {
        if (!matchRepository.existsById(id)) {
            throw new EntityNotFoundException("Match non trouvé avec l'id : " + id);
        }
        matchRepository.deleteById(id);
    }
}
